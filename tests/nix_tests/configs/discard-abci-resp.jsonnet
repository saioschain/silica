local config = import 'default.jsonnet';

config {
  'sai_6800-1'+: {
    config+: {
      storage: {
        discard_abci_responses: true,
      },
    },
  },
}
