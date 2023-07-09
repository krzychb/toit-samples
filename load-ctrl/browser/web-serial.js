/*
 Inspired by "Getting Started with Web Serial" Codelab
 https://codelabs.developers.google.com/codelabs/web-serial/
 */

'use strict';

let port;
let reader;
let inputDone;
let outputDone;
let inputStream;
let outputStream;

const logWindow = document.getElementById('logWindow');
const buttonConnect = document.getElementById('buttonConnect');
const buttonSend = document.getElementById('buttonSend');
const setpointEntry = document.getElementById('setpointEntry');


/**
 * Shows information if the browser doesn't support Web Serial API.
 */
document.addEventListener('DOMContentLoaded', () => {
  buttonConnect.addEventListener('click', clickConnect);
  buttonSend.addEventListener('click', clickSend);

  const notSupported = document.getElementById('notSupported');
  notSupported.classList.toggle('hidden', 'serial' in navigator);
});


/**
 * @name connect
 * Opens a Web Serial connection and sets up the input and
 * output stream.
 */
async function connect() {

  // Request a port by showing a dialog with a list of ports.
  port = await navigator.serial.requestPort();

  // Wait for the port to open.
  await port.open({ baudRate: 115200 });
  /*
  Close the port to reset it.
  This extra step is required on Windows system
  to avoid "DOMException: Buffer overrun" error
  if reconnecting to the same port.
  */
  await port.close();
  await port.open({ baudRate: 115200 });

  // Setup the output stream.
  const encoder = new TextEncoderStream();
  outputDone = encoder.readable.pipeTo(port.writable);
  outputStream = encoder.writable;

  // Read the stream.
  let decoder = new TextDecoderStream();
  inputDone = port.readable.pipeTo(decoder.writable);
  inputStream = decoder.readable
    .pipeThrough(new TransformStream(new LineBreakTransformer()));

  reader = inputStream.getReader();
  readLoop();
}


/**
 * @name readLoop
 * Reads data from the input stream and displays it on screen.
 */
async function readLoop() {

  // Set the desired limit for the number of lines to display.
  const logLimit = 10;
  let logLines = [];

  while (true) {
    const { value, done } = await reader.read();
    if (value) {
      logLines.push(value);
      if (logLines.length > logLimit) {
        logLines.shift();
      }
      logWindow.textContent =  logLines.join('\n');
      if (value.includes('[To UI]')) {
        addToChart(value)
      }
    }
    if (done) {
      console.log('[readLoop] Done.', done);
      reader.releaseLock();
      break;
    }
  }
}


/**
 * @name LineBreakTransformer
 * TransformStream to parse the stream into lines.
 */
class LineBreakTransformer {
  constructor() {
    // A container for holding stream data until a new line.
    this.container = '';
  }

  // Handle incoming chunk
  transform(chunk, controller) {
    this.container += chunk;
    const lines = this.container.split('\r\n');
    this.container = lines.pop();
    lines.forEach(line => controller.enqueue(line));
  }

    // Flush the stream.
    flush(controller) {
    controller.enqueue(this.container);
  }
}


/**
 * @name writeToStream
 * Gets a writer from the output stream and send the lines to the serial port.
 * @param  {...string} lines lines to send to the serial port.
 */
function writeToStream(...lines) {
  const writer = outputStream.getWriter();
  lines.forEach((line) => {
    console.log('[SEND]', line);
    writer.write(line + '\n');
  });
  writer.releaseLock();
}


/**
 * @name disconnect
 * Closes the Web Serial connection.
 */
async function disconnect() {

  // Close the input stream (reader).
  if (reader) {
    await reader.cancel();
    await inputDone.catch(() => {});
    reader = null;
    inputDone = null;
  }

  // Close the output stream.
  if (outputStream) {
    await outputStream.getWriter().close();
    await outputDone;
    outputStream = null;
    outputDone = null;
  }

  // Close the port.
  await port.close();
  port = null;
}


/**
 * @name clickConnect
 * Click handler for the Connect/Disconnect button.
 */
async function clickConnect() {

  if (port) {
    await disconnect();
    toggleUIConnected(false);
    return;
  }

  await connect();
  toggleUIConnected(true);
}


/**
 * @name toggleUIConnected
 * Toggle text on Connect/Disconnect button.
 */
function toggleUIConnected(connected) {
  let lbl = 'Connect';
  if (connected) {
    lbl = 'Disconnect';
  }
  buttonConnect.textContent = lbl;
}


/**
 * @name clickSend
 * Click handler for the Send button.
 */
async function clickSend() {

  if (port) {
    setpointEntry.value = setpointEntry.value.trim();
    writeToStream('SP: ' + setpointEntry.value);
  }
}
