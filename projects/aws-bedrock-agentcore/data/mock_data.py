FLIGHTS = {
    ("GRU", "LIS"): [
        {"airline": "TAP Air Portugal", "flight": "TP083", "duration": "9h30", "price_brl": 3200, "stops": 0},
        {"airline": "Iberia",           "flight": "IB6830","duration": "11h15","price_brl": 2800, "stops": 1},
        {"airline": "LATAM",            "flight": "LA8062","duration": "12h00","price_brl": 2600, "stops": 1},
    ],
    ("GRU", "CDG"): [
        {"airline": "Air France",       "flight": "AF457", "duration": "11h20","price_brl": 4100, "stops": 0},
        {"airline": "TAP Air Portugal", "flight": "TP089", "duration": "13h00","price_brl": 3500, "stops": 1},
        {"airline": "LATAM",            "flight": "LA702", "duration": "14h30","price_brl": 3200, "stops": 1},
    ],
    ("GRU", "NRT"): [
        {"airline": "ANA",              "flight": "NH9822","duration": "24h00","price_brl": 6500, "stops": 1},
        {"airline": "Korean Air",       "flight": "KE951", "duration": "26h00","price_brl": 5800, "stops": 1},
        {"airline": "Emirates",         "flight": "EK262", "duration": "28h00","price_brl": 5500, "stops": 1},
    ],
}

HOTELS = {
    "Lisboa": [
        {"name": "Generator Lisbon",      "neighborhood": "Mouraria",    "price_night": 120, "rating": 8.2, "tier": "budget"},
        {"name": "Hotel Bairro Alto",     "neighborhood": "Chiado",      "price_night": 280, "rating": 9.0, "tier": "medium"},
        {"name": "Bairro Alto Hotel",     "neighborhood": "Príncipe Real","price_night": 520, "rating": 9.4, "tier": "premium"},
    ],
    "Paris": [
        {"name": "St Christopher's Inn", "neighborhood": "Gare du Nord", "price_night": 90,  "rating": 7.8, "tier": "budget"},
        {"name": "Hotel Fabric",         "neighborhood": "Oberkampf",    "price_night": 220, "rating": 8.9, "tier": "medium"},
        {"name": "Hôtel Le Marois",      "neighborhood": "Champs-Élysées","price_night":480, "rating": 9.2, "tier": "premium"},
    ],
    "Tokyo": [
        {"name": "Khaosan Tokyo Kabuki", "neighborhood": "Asakusa",      "price_night": 80,  "rating": 8.0, "tier": "budget"},
        {"name": "Shinjuku Granbell",    "neighborhood": "Shinjuku",     "price_night": 180, "rating": 8.7, "tier": "medium"},
        {"name": "Park Hyatt Tokyo",     "neighborhood": "Shinjuku",     "price_night": 650, "rating": 9.5, "tier": "premium"},
    ],
}

ACTIVITIES = {
    "Lisboa": [
        {"day": 1, "activities": ["Castelo de São Jorge", "Alfama e Fado ao vivo", "Time Out Market"]},
        {"day": 2, "activities": ["Belém — Torre e Mosteiro dos Jerónimos", "Pastéis de Belém", "MAAT"]},
        {"day": 3, "activities": ["Sintra — Palácio da Regaleira + Pena", "Cascais ao pôr do sol"]},
        {"day": 4, "activities": ["LX Factory", "Barrio Alto", "Cervejaria Ramiro"]},
        {"day": 5, "activities": ["Mercado da Ribeira", "Museu do Azulejo", "Parque das Nações"]},
    ],
    "Paris": [
        {"day": 1, "activities": ["Torre Eiffel", "Champ de Mars picnic", "Cruzeiro no Sena"]},
        {"day": 2, "activities": ["Louvre (manhã)", "Tuileries", "Marais e Place des Vosges"]},
        {"day": 3, "activities": ["Versalhes (dia inteiro)"]},
        {"day": 4, "activities": ["Montmartre", "Sacré-Cœur", "Moulin Rouge à noite"]},
        {"day": 5, "activities": ["Musée d'Orsay", "Saint-Germain-des-Prés", "jantar bistrô"]},
    ],
    "Tokyo": [
        {"day": 1, "activities": ["Shibuya Crossing", "Harajuku", "Meiji Shrine"]},
        {"day": 2, "activities": ["Asakusa — Senso-ji", "Akihabara", "Sumida River"]},
        {"day": 3, "activities": ["Tsukiji Outer Market", "Ginza", "teamLab Borderless"]},
        {"day": 4, "activities": ["Shinjuku Gyoen", "Kabukicho", "izakaya crawl"]},
        {"day": 5, "activities": ["Yanaka (bairro antigo)", "Ueno Park e museus", "Roppongi Hills"]},
    ],
}

AIRPORT_CODES = {
    "Lisboa": "LIS",
    "Paris":  "CDG",
    "Tokyo":  "NRT",
}

SUPPORTED_DESTINATIONS = list(HOTELS.keys())
