// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "spectre.css/dist/spectre.css";
import "spectre.css/dist/spectre-exp.css";
import "select2/dist/css/select2.css";
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

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
import init from "./init";
import icons from "./icons";
