import pytest

from .network import setup_evmos, setup_geth


@pytest.fixture(scope="session")
def evmos(tmp_path_factory):
    path = tmp_path_factory.mktemp("sai")
    yield from setup_evmos(path, 26650)


@pytest.fixture(scope="session")
def geth(tmp_path_factory):
    path = tmp_path_factory.mktemp("geth")
    yield from setup_geth(path, 8545)


@pytest.fixture(scope="session", params=["sai", "evmos-ws"])
def evmos_rpc_ws(request, evmos):
    """
    run on both evmos and evmos websocket
    """
    provider = request.param
    if provider == "sai":
        yield evmos
    elif provider == "evmos-ws":
        evmos_ws = evmos.copy()
        evmos_ws.use_websocket()
        yield evmos_ws
    else:
        raise NotImplementedError


@pytest.fixture(scope="module", params=["sai", "evmos-ws", "geth"])
def cluster(request, evmos, geth):
    """
    run on evmos, evmos websocket and geth
    """
    provider = request.param
    if provider == "sai":
        yield evmos
    elif provider == "evmos-ws":
        evmos_ws = evmos.copy()
        evmos_ws.use_websocket()
        yield evmos_ws
    elif provider == "geth":
        yield geth
    else:
        raise NotImplementedError
