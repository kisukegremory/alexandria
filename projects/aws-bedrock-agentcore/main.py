import sys
from agents.supervisor import supervisor


def main() -> None:
    request = " ".join(sys.argv[1:]) if len(sys.argv) > 1 else (
        "Quero viajar para Lisboa em julho, 5 dias, 2 pessoas, budget médio."
    )
    print(f"\nRequest: {request}\n{'─' * 60}")
    response = supervisor(request)
    print(response)


if __name__ == "__main__":
    main()
