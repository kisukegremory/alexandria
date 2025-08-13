import typer

app = typer.Typer(help="Nina - gerador de miados")

@app.command()
def run(
    output: str = typer.Option("console", "--output", "-o", help="Saída [console | arquivo.md]")
):
    if output == "console":
        typer.secho("Nina: Nya nya nya", fg=typer.colors.GREEN)
    else:
        with open(output, "w") as f:
            f.write("Nina: Nya nya nya")