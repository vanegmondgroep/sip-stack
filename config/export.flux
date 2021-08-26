from(bucket: "sip")
  |> range(start: -24h)
  |> drop(columns: ["_start", "_stop"])
  |> yield(name: "mean")
