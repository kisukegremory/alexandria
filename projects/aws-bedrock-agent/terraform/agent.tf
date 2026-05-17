resource "aws_bedrockagent_agent" "techcorp" {
  agent_name              = local.project_name
  agent_resource_role_arn = aws_iam_role.agent_execution.arn
  foundation_model        = local.agent_model

  instruction = <<-EOT
    You are an IT Service Desk assistant for TechCorp. Help employees resolve IT issues efficiently.

    Process:
    1. Search the knowledge base for documented solutions to the user's problem.
    2. If a solution is found in the knowledge base, provide it directly — do NOT create a ticket.
    3. If no documented solution exists, create a support ticket using create_ticket.
    4. When asked about ticket status, use get_ticket_status with the ticket ID.
    5. When the user wants to escalate an unresolved issue, use escalate_ticket.

    Always be professional, concise, and empathetic. If the issue is unclear, create the ticket anyway and note it needs follow-up.
  EOT
}

resource "aws_bedrockagent_agent_action_group" "tickets" {
  agent_id          = aws_bedrockagent_agent.techcorp.agent_id
  agent_version     = "DRAFT"
  action_group_name = "TicketManagement"
  description       = "Create, check status, and escalate IT support tickets"

  action_group_executor {
    lambda = aws_lambda_function.action_groups.arn
  }

  function_schema {
    member_functions {
      functions {
        name        = "create_ticket"
        description = "Create a new IT support ticket for an unresolved issue not covered by the knowledge base"
        parameters {
          map_block_key = "user_id"
          type          = "string"
          description   = "Employee ID or email of the user reporting the issue"
          required      = false
        }
        parameters {
          map_block_key = "category"
          type          = "string"
          description   = "Issue category: HARDWARE, SOFTWARE, NETWORK, ACCESS, OTHER"
          required      = true
        }
        parameters {
          map_block_key = "description"
          type          = "string"
          description   = "Detailed description of the IT issue"
          required      = true
        }
        parameters {
          map_block_key = "priority"
          type          = "string"
          description   = "Priority: LOW, MEDIUM, HIGH, CRITICAL"
          required      = false
        }
      }

      functions {
        name        = "get_ticket_status"
        description = "Get the current status of an existing support ticket"
        parameters {
          map_block_key = "ticket_id"
          type          = "string"
          description   = "The ticket ID, e.g. TK-001"
          required      = true
        }
      }

      functions {
        name        = "escalate_ticket"
        description = "Escalate a ticket to Tier 2 support when the issue is unresolved or urgent"
        parameters {
          map_block_key = "ticket_id"
          type          = "string"
          description   = "The ticket ID to escalate"
          required      = true
        }
        parameters {
          map_block_key = "reason"
          type          = "string"
          description   = "Reason for escalation"
          required      = true
        }
      }
    }
  }
}

resource "aws_bedrockagent_agent_knowledge_base_association" "docs" {
  agent_id             = aws_bedrockagent_agent.techcorp.agent_id
  agent_version        = "DRAFT"
  knowledge_base_id    = aws_bedrockagent_knowledge_base.techcorp.id
  knowledge_base_state = "ENABLED"
  description          = "TechCorp IT troubleshooting documentation"
}

resource "aws_bedrockagent_agent_alias" "live" {
  agent_id         = aws_bedrockagent_agent.techcorp.agent_id
  agent_alias_name = "live"
}
