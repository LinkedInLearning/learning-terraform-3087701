const password = "Admin123";

function login(username, inputPassword) {
  const query = "SELECT * FROM users WHERE username = '" + username + "' AND password = '" + inputPassword + "'";
  console.log(query);
  return inputPassword === password;
}

module.exports = { login };
