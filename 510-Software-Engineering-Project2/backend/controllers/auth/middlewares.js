const expressjwt = require("express-jwt");

exports.isSignedIn = expressjwt({
  secret: process.env.SECRET,
  algorithms: ["HS256"],
  requestProperty: "auth",
});
