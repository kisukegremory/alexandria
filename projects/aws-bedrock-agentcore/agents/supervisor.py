import sys
from strands import Agent, tool
from strands.models import BedrockModel
from agents.flights import flights_agent
from agents.accommodation import accommodation_agent
from agents.activities import activities_agent


@tool
def find_flights(request: str) -> str:
    """Delegate a flight search request to the flights specialist agent."""
    print("  [→ flights agent]", file=sys.stderr)
    return str(flights_agent(request))


@tool
def find_accommodation(request: str) -> str:
    """Delegate a hotel search request to the accommodation specialist agent."""
    print("  [→ accommodation agent]", file=sys.stderr)
    return str(accommodation_agent(request))


@tool
def find_activities(request: str) -> str:
    """Delegate an activities and itinerary request to the activities specialist agent."""
    print("  [→ activities agent]", file=sys.stderr)
    return str(activities_agent(request))


supervisor = Agent(
    model=BedrockModel(model_id="amazon.nova-pro-v1:0"),
    tools=[find_flights, find_accommodation, find_activities],
    callback_handler=None,
    system_prompt="""You are a travel planning coordinator for a Brazilian travel agency.
Your job is to gather information from specialist agents and synthesize a complete travel plan.

ROUTING RULES — follow these exactly:
- Call find_flights ONLY if the user needs transportation (no mention of "já tenho voo", "voo próprio").
- Call find_accommodation ONLY if the user needs lodging (no mention of "já tenho hotel", "já tenho onde ficar", "hospedagem garantida").
- Call find_activities whenever a destination and duration are provided.
- If the destination is not Lisboa, Paris or Tokyo, respond gracefully that you cannot assist with that destination yet.

After collecting results from the relevant agents, synthesize everything into a clear,
friendly day-by-day travel plan in the same language as the user.""",
)
