const express = require('express');
const bodyParser = require('body-parser');
const sinchTicketGen = require('sinch-ticketgen');

const APPKEY = 'a08df457-78e8-4bd5-bb95-c93ce2d25c1e';
const APPSECRET = 'R2Bi1UluMEW3GtyHG7f+Iw==';

const app = express();

app.use(bodyParser.json())

app.post('/', (req, res) => {
  const body = req.body;
  // console.log(JSON.stringify(body, null, 2));
  switch (body.event) {
    // incoming call event
    case 'ice':
      if (body.user === 'dani' && body.to.endpoint === 'gabro') {
        console.log('Call allowed');
        res.send('👍');
      } else {
        console.log('Call not allowed');
        res.status(403).send('🚫');
      }
      break;
    default: res.send('👍');
  }
});


app.post('/auth', (req, res) => {
  const body = req.body;
  console.log(JSON.stringify(body, null, 2));
  const username = 'gabro';
  const authTicket = sinchTicketGen(APPKEY, APPSECRET, { username }, new Date('4/5/16'));

  res.json({ authTicket });
});

app.listen(3000, function () {
  console.log('Listening on port 3000!');
});
