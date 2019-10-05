// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "datatables.net-dt/css/jquery.dataTables.min.css";
import "datatables.net-fixedheader-dt/css/fixedHeader.dataTables.min.css";
import "spectre.css/dist/spectre.min.css";
import "spectre.css/dist/spectre-exp.min.css";
import "select2/dist/css/select2.min.css";
import "../css/app.css";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html";
import "select2";
import "datatables.net";
import "datatables.net-fixedheader";

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
import init from "./init";
import icons from "./icons";
