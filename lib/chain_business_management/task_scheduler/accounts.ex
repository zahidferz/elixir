defmodule ChainBusinessManagement.TaskScheduler.Accounts do
  @moduledoc """
    Cron-like scheduler for operations regarding Accounts
  """

  alias ChainBusinessManagement.Accounts
  use Quantum, otp_app: :chain_business_management

  import Crontab.CronExpression
  require Logger

  def setup_jobs do
    set_overdue_expected_operations_job()
  end

  defp set_overdue_expected_operations_job do
    new_job()
    |> Quantum.Job.set_name(:set_overdue_expected_operations)
    |> Quantum.Job.set_schedule(~e[0 5 * * *])
    |> Quantum.Job.set_timezone("America/Mexico_City")
    |> Quantum.Job.set_task(fn ->
      try do
        current_timestamp = get_current_timestamp_mx()
        Logger.info("Starting job set_overdue_expected_operations/1")
        Accounts.set_overdue_expected_operations(current_timestamp)
        Logger.info("job set_overdue_expected_operations/1 finished")
      rescue
        err ->
          Sentry.capture_exception(err,
            stacktrace: __STACKTRACE__,
            extra: %{extra: "set_overdue_expected_operations/1"}
          )
      end
    end)
    |> add_job()
  end

  defp get_current_timestamp_mx() do
    {:ok, datetime_tz_now} =
      Timex.now("America/Mexico_City")
      |> Timex.format("%FT%TZ", :strftime)

    datetime_tz_now
  end
end
