module M = [%csv "http://ichart.finance.yahoo.com/table.csv?s=MSFT"]
module N = [%csv "./test.csv"]

let _ =
  print_endline "Date | Open | High | Low | Close | Volume | Adj Close";
  ignore @@ List.map
    (function
      [d; o; h; l; c; v; a] ->
        Printf.printf "%s | %s | %s | %s | %s | %s | %s\n" d o h l c v a) (snd N.embed);
  print_endline "\nShowing items 0...2";
  print_endline "Date | Open | High | Low | Close | Volume | Adj Close";
  ignore @@ List.map
    N.(function
      {date = d; open_ = o; high = h; low = l; close = c; volume = v; adjClose = a} ->
        Printf.printf "%s | %f | %f | %f | %f | %d | %f\n" d o h l c v a)
    (snd @@ N.get_sample ~amount:3 N.embed);
  print_endline "\nShowing items 1...3";
  ignore @@ List.map
    N.(function
      {date = d; open_ = o; high = h; low = l; close = c; volume = v; adjClose = a} ->
        Printf.printf "%s | %f | %f | %f | %f | %d | %f\n" d o h l c v a)
    (snd @@ N.range ~from:1 ~until:3 (N.rows N.embed));
  let open N in
  let open Lwt in
  let data = Lwt_main.run (N.local_load "test/test.csv" >>= fun t ->
    return @@ N.map (fun x -> {x with high = x.high +. 100.}) (N.rows t)) in
  let data = N.filter (fun x -> x.volume > 50000000) data in
  List.map (fun d -> Printf.printf "%f\n" d.high) (snd data);
  print_endline "\nPretty-printing data with `show`...";
  print_endline @@ N.show data;
  print_endline "\nLoading stock data from Yahoo Finance...";
  let open Lwt in Lwt_main.run begin
  N.load "http://ichart.finance.yahoo.com/table.csv?s=MSFT" >>= fun csv ->
  return @@ print_endline @@ N.show @@ N.take 100 @@ N.rows csv end;
  N.save ~name:"test/test_result.csv" (N.raw data);
  print_endline "\nCompleted all tests!"
