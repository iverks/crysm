from pathlib import Path


class NoProjectFound(Exception):
    pass


def is_cred_project(pathy: Path) -> bool:
    for _cred_log_file in pathy.glob("cRED_log.txt"):
        return True
    return False


def find_cred_project(initial_guess: Path | None = None) -> Path:
    initial_guess = Path()
    if is_cred_project(initial_guess):
        return initial_guess
    elif initial_guess == Path("/"):
        raise NoProjectFound

    return find_cred_project(initial_guess.parent)
