from typer import Typer

app = Typer(name="crysm")


def main():
    """Alias for uv"""
    print("Still using main instead of app")
    app()


@app.command()
def empty():
    print("Hello from the crysm package. Someday I will give you some useful cli help.")


if __name__ == "__main__":
    app()
