from strands import Agent
from strands.models import BedrockModel
from tools.activity_tools import get_activities

activities_agent = Agent(
    model=BedrockModel(model_id="amazon.nova-lite-v1:0"),
    tools=[get_activities],
    system_prompt=(
        "You are a travel activities specialist. "
        "When given a travel request, extract destination, number of days and traveler profile. "
        "If duration is not specified, assume 5 days. "
        "If traveler profile is not specified, assume 'cultural'. "
        "NEVER ask for clarification — always call get_activities immediately with the best available values. "
        "Always respond in the same language as the user."
    ),
)
