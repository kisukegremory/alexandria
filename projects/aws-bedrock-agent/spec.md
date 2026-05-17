# aws-bedrock-agent — Spec & Production Discoveries

## Overview

IT Service Desk agent for fictional company TechCorp. Study project for AWS AIF-C01 certification, covering Bedrock Agents API: ReAct orchestration, action groups, function schema, Knowledge Base integration, and session memory.

## Architecture

```
User message
     │
     ▼
aws_bedrockagent_agent (Nova Lite)
     │ ReAct loop (AWS-managed)
     ├─── KB retrieval (S3 Vectors / Titan Embed)
     │         Documented issue? → reply directly
     │
     └─── Lambda action_groups (create/status/escalate)
               Not documented? → create_ticket → TK-XXX
```

## Action Groups

| Function | Parameters | Description |
|----------|-----------|-------------|
| `create_ticket` | user_id, category, description, priority? | Creates ticket, returns TK-XXX |
| `get_ticket_status` | ticket_id | Returns status, category, priority |
| `escalate_ticket` | ticket_id, reason | Sets status=ESCALATED |

Lambda uses a module-level `TICKETS` dict as mock storage (resets on cold start — intentional for study).

## Workflow

```
make init          # terraform init
make apply         # provision all infra
make prepare       # prepare agent DRAFT version (required before invoking)
make upload-docs   # sync docs/ to S3
make ingest        # start KB ingestion job
make ingest-status # check ingestion progress
make invoke MSG="" # single-turn invoke
make chat MSG=""   # multi-turn (SESSION_ID persists within same make invocation)
make test          # run 7 scenarios
make publish       # taint alias + apply (publishes new agent version after changes)
```

## Terraform Resources

| File | Resources |
|------|----------|
| `providers.tf` | AWS provider, profile "nina", us-east-1 |
| `locals.tf` | project_name, embed_model (Titan Embed v2), agent_model (Nova Lite) |
| `iam.tf` | kb_execution role (S3 read + S3 Vectors + Titan embed), agent_execution role (InvokeModel + Lambda invoke + KB retrieve), lambda_execution role (basic execution) |
| `s3.tf` | docs bucket (force_destroy=true) |
| `kb.tf` | S3 Vectors vector bucket + index (1024-dim cosine), KB resource, data source with fixed-size chunking (200 tokens, 10% overlap) |
| `lambda.tf` | archive_file zip, Lambda py3.12, bedrock Lambda permission |
| `agent.tf` | Agent with instruction, action group (function_schema), KB association, alias |
| `outputs.tf` | agent_id, agent_alias_id, kb_id, data_source_id, docs_bucket_name |

## Production Discoveries

### 1. Agent must be "prepared" before invocation
After `terraform apply` (or any change to the agent, action groups, or KB association), you must call `PrepareAgent` before invoking. Without this, invocations return a validation error. `make prepare` handles this.

### 2. Alias is required for InvokeAgent
`InvokeAgent` requires an `agentAliasId` — you cannot invoke the DRAFT version directly. The alias created by `aws_bedrockagent_agent_alias` maps to the most recently prepared version.

### 3. function_schema vs OpenAPI
Bedrock Agents supports two action group schema modes:
- **OpenAPI**: full YAML/JSON schema, flexible but verbose
- **function_schema** (used here): native Terraform HCL with `member_functions` blocks, cleaner for Terraform-managed projects

### 4. Lambda event format (function_schema mode)
```python
{
  "function": "create_ticket",        # not "apiPath"
  "parameters": [
    {"name": "user_id", "type": "string", "value": "joao@techcorp.com"},
    {"name": "category", "type": "string", "value": "HARDWARE"},
  ]
}
```
Response must be:
```python
{"response": {"functionResponse": {"responseBody": {"TEXT": {"body": "..."}}}}}
```

### 5. Lambda TICKETS dict resets on cold start
The mock in-memory store is intentional for this study project. In production, use DynamoDB or similar. Cold start = tickets disappear; same execution environment = tickets persist between invocations. This is fine for single-session testing.

### 6. publish vs prepare
- `make prepare` → only prepares DRAFT (needed for `DRAFT` invocation or first alias creation)
- `make publish` → taint + apply → Terraform recreates the alias, which creates a new numbered version from the current DRAFT and points the alias at it. Use after any content change.

### 7. ReAct loop and KB vs action group routing
The agent decides autonomously whether to retrieve from KB or call a Lambda function. The instruction text matters: explicitly telling the agent "if KB has the answer, do NOT create a ticket" significantly reduces unnecessary ticket creation. Vague instructions cause the agent to create tickets for every issue.

### 8. S3 Vectors index requires non_filterable_metadata_keys for Bedrock KB
By default, every field stored by Bedrock KB in S3 Vectors counts toward the 2048-byte filterable metadata limit. Bedrock KB uses two keys — `AMAZON_BEDROCK_TEXT_CHUNK` (the chunk text) and `AMAZON_BEDROCK_METADATA` (source/doc metadata) — which easily exceed that limit for any real document. The fix is to declare them as non-filterable in the index:
```hcl
metadata_configuration {
  non_filterable_metadata_keys = ["AMAZON_BEDROCK_TEXT_CHUNK", "AMAZON_BEDROCK_METADATA"]
}
```
The text is still stored and returned during retrieval; it just can't be used as a vector search filter, which is fine for RAG.

### 9. Session memory scope
Session memory is scoped to the `sessionId` passed to `InvokeAgent`. The agent remembers the conversation context within one session. Across different session IDs, memory is independent. Cross-session (long-term) memory requires explicit Bedrock Memory configuration.

## Test Scenarios

| # | Scenario | Covers |
|---|----------|--------|
| 1 | VPN issue → KB hit → no ticket | KB retrieval, instruction following |
| 2 | Unknown driver issue → KB miss → create_ticket | ReAct, action group invocation |
| 3 | get_ticket_status for created ticket | action group → Lambda |
| 4 | escalate_ticket | action group → Lambda, status mutation |
| 5a | Multi-turn: create ticket | session memory |
| 5b | Multi-turn: status in same session | session continuity |
| 5c | Multi-turn: escalate in same session | multi-step reasoning |
