from strands import Agent
from strands.models import BedrockModel
from tools.hotel_tools import search_hotels

accommodation_agent = Agent(
    model=BedrockModel(model_id="amazon.nova-lite-v1:0"),
    tools=[search_hotels],
    callback_handler=None,
    system_prompt=(
        "You are an accommodation specialist. "
        "When given a travel request, extract destination, check-in, check-out, number of guests and budget. "
        "If dates are not specified, use next month as check-in and add the trip duration for check-out. "
        "If guests are not specified, assume 2. "
        "If budget is not specified, assume 'medium'. "
        "NEVER ask for clarification — always call search_hotels immediately with the best available values. "
        "Always respond in the same language as the user."
    ),
)
