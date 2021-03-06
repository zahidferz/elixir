{application,crontab,
             [{applications,[kernel,stdlib,elixir,logger]},
              {description,"Parse Cron Format Strings, Write Cron Format Strings and Calculate Execution Dates.\n"},
              {modules,['Elixir.Crontab.CronExpression',
                        'Elixir.Crontab.CronExpression.Composer',
                        'Elixir.Crontab.CronExpression.Ecto.Type',
                        'Elixir.Crontab.CronExpression.Parser',
                        'Elixir.Crontab.DateChecker',
                        'Elixir.Crontab.DateHelper',
                        'Elixir.Crontab.Scheduler',
                        'Elixir.Inspect.Crontab.CronExpression']},
              {registered,[]},
              {vsn,"1.1.10"}]}.
