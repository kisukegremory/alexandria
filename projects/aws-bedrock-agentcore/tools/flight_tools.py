import json
from strands import tool
from data.mock_data import FLIGHTS, AIRPORT_CODES, SUPPORTED_DESTINATIONS


@tool
def search_flights(origin: str, destination: str, date: str, passengers: int) -> str:
    """
    Search for available flights from origin to destination.

    Args:
        origin: Departure city name (e.g. 'São Paulo')
        destination: Arrival city name — must be one of: Lisboa, Paris, Tokyo
        date: Travel date in YYYY-MM-DD format
        passengers: Number of passengers

    Returns:
        JSON string with available flight options including airline, flight number,
        duration, price in BRL, and number of stops.
    """
    dest_code = AIRPORT_CODES.get(destination)
    if not dest_code:
        return json.dumps({
            "error": f"Destination '{destination}' not available. Supported: {SUPPORTED_DESTINATIONS}"
        })

    options = FLIGHTS.get(("GRU", dest_code), [])
    result = [
        {**f, "passengers": passengers, "total_brl": f["price_brl"] * passengers}
        for f in options
    ]
    return json.dumps({"destination": destination, "date": date, "options": result}, ensure_ascii=False)
