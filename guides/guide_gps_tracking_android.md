# GPS tracking

## Context

- During the census phase of the Bohemia project, the location of data capture devices (tablets) will be tracked. The purpose of this tracking is to both:
  - Help with recovery in the case of device loss or theft
  - Enable, over time, the identification of travel routes through the aggregation of the GPS tracks/paths taken by each tablet, and the subsequent generation of travel route planning tools and maps
- This guide details the technical set-up of the device tracking system

### Services used

- Device-side: Devices will use Traccar Client, and Android application downloadable via the [Google Play Store](https://play.google.com/store/apps/details?id=org.traccar.client).
- Server-side: The server will run Traccar Server, downloadable from Traccar's [website](https://github.com/traccar/traccar/releases/download/v4.8/traccar-linux-64-4.8.zip)


### Server details

- Databrew will manage all server-side operations for GPS tracking.
- Databrew will supply all GPS data to local sites.
- Local sites do not need to do anything related to GPS tracking other than the installing and configuring the android application (see below)
- The [GPS tracking server page](guide_gps_tracking_server.md) has details on configuring and deploying a server for capturing device locations.

## Steps

### Installation

- Install Traccar client via the [Google Play Store](https://play.google.com/store/apps/details?id=org.traccar.client)

### Configuration

- Open the Traccar app
- Set the address of the server URL: `http://bohemia.fun`
- Set the Frequency field to: `60`
- Set location accuracy to: `high`
- Do not change the Distance or Angles fields
- At the top set "Service status" to on/running

### Use

- The Traccar app should be running ("Service status" set to on) at all times during operations
- The app will automatically initialize upon device reboot
- If for some reason the app is turned off, workers should turn it back on
- We have tested the app on many devices. At the 60 second recording interval, it has only minimal effect on battery life.
- When the device is offline, GPS coordinates are stored locally; when an internet connection is found, GPS coordinates are sent to the server.
