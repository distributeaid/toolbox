{application,prometheus_ecto,
             [{applications,[kernel,stdlib,elixir,logger,prometheus_ex]},
              {description,"Prometheus monitoring system client Ecto integration. Observes queries duration.\n"},
              {modules,['Elixir.Prometheus.EctoInstrumenter',
                        'Elixir.Prometheus.EctoInstrumenter.Config']},
              {registered,[]},
              {vsn,"1.4.3"}]}.
