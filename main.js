'use strict'

const electron = require('electron')

const app = electron.app
const BrowserWindow = electron.BrowserWindow

let mainWindow // global ref to mainWindow

app.on('ready', createWindow)

function createWindow () {
  mainWindow = new BrowserWindow({
    width: 1024,
    height: 768
  })

  mainWindow.loadURL(`file://${__dirname}/src/static/index.html`)

  // devtools on by default
  mainWindow.webContents.openDevTools()

  mainWindow.on('closed', function () {
    mainWindow = null
  })
}

/* Mac Specific */

// closing all windows on non-mac quits the app
app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') { app.quit() }
})

// if there's no main window create one
app.on('activate', () => {
  if (mainWindow === null) { createWindow() }
})
