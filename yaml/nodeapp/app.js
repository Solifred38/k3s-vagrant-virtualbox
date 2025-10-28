const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send('Hello from custom Node.js app running in Minikube!');
});

const port = 3000;
app.listen(port, () => {
  console.log(`App listening on port ${port}`);
});

