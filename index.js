const express = require('express')
const fs = require('fs');
const app = express()
const port = 3000

// Event that flushes the header as soon as the request is received
app.get('/events', async function (req, res) {
    console.log('Got /events');
    res.set({
        'Cache-Control': 'no-cache',
        'Content-Type': 'text/event-stream',
        'Connection': 'keep-alive'
    });
    res.flushHeaders();

    // Tell the client to retry every 10 seconds if connectivity is lost
    res.write('retry: 10000\n\n');
    let count = 0;
    let isAlive = true;

    res.socket.on('end', e => {
        console.log('event source closed');
        isAlive = false;
    });

    while (isAlive) {
        await new Promise(resolve => setTimeout(resolve, 1000));

        console.log('Emit', ++count);
        // Emit an SSE that contains the current 'count' as a string
        res.write(`data: ${count}\n\n`);
    }

    res.end();
});

// sse that waits 10 seconds before flushing the headers
app.get('/eventWithDelay', async function (req, res) {
    console.log('Got /eventWithGap');
    res.set({
        'Cache-Control': 'no-cache',
        'Content-Type': 'text/event-stream',
        'Connection': 'keep-alive'
    });
    
    // create a delay of 10s before header flush
    await new Promise(resolve => setTimeout(resolve, 10000));
    res.flushHeaders();

    // Tell the client to retry every 10 seconds if connectivity is lost
    res.write('retry: 10000\n\n');
    let count = 0;
    let isAlive = true;

    res.socket.on('end', e => {
        console.log('event source closed');
        isAlive = false;
    });

    while (isAlive) {
        await new Promise(resolve => setTimeout(resolve, 1000));

        console.log('Emit', ++count);
        // Emit an SSE that contains the current 'count' as a string
        res.write(`data: ${count}\n\n`);
    }

    res.end();
});

const index = fs.readFileSync('./index.html', 'utf8');
app.get('/', (req, res) => res.send(index));


app.listen(port, () => {
    console.log(`Example app listening on port ${port}`)
})
