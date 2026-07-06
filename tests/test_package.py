"""Smoke test for the package scaffold."""

from aemet_etl import __version__


def test_version_is_set() -> None:
    """The package exposes a semantic version string."""
    assert __version__.count(".") == 2
