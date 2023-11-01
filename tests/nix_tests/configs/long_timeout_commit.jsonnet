local default = import 'default.jsonnet';

default {
  'sai_6800-1'+: {
    config+: {
      consensus+: {
        timeout_commit: '5s',
      },
    },
  },
}
