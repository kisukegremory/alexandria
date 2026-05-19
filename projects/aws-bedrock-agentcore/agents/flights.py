from strands import Agent
from strands.models import BedrockModel
from tools.flight_tools import search_flights

flights_agent = Agent(
    model=BedrockModel(model_id="amazon.nova-lite-v1:0"),
    tools=[search_flights],
    system_prompt=(
        "You are a flight search specialist. "
        "When given a travel request, extract origin, destination, date and number of passengers. "
        "If origin is not specified, assume 'São Paulo'. "
        "If date is not specified, assume next month in YYYY-MM-DD format. "
        "If passengers are not specified, assume 1. "
        "NEVER ask for clarification — always call search_flights immediately with the best available values. "
        "Always respond in the same language as the user."
    ),
)
