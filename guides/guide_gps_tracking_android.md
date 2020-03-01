# GPS tracking

## Context

- During the census phase of the Bohemia project, the location of data capture devices (tablets) will be tracked. The purpose of this tracking is to both:
  - Help with recovery in the case of device loss or theft
  - Enable, over time, the identification of travel routes through the aggregation of the GPS tracks/paths taken by each tablet, and the subsequent generation of travel route planning tools and maps
- This guide details the technical set-up of the device tracking system

### Services used

- Device-side: Devices will use Traccar Client, and Android application downloadable via the [Google Play Store](https://play.google.com/store/apps/details?id=org.traccar.client).
- Server-side: The server will run Traccar Server, downloadable from Traccar's [website](https://github.com/traccar/traccar/releases/download/v4.8/traccar-linux-64-4.8.zip)

## Steps

### On server

Please visit the [GPS tracking server page](guide_gps_tracking_server.md) for details on configuring and deploying a server for capturing device locations

### On android device


- Install Traccar client via the [Google Play Store](https://play.google.com/store/apps/details?id=org.traccar.client)
- Set the "Device identifier" field to the ID number of the fieldworker
- Set the address of the server URL: `bohemia.fun`
- Set "Service status" to on/running
- Click on "Status" in the upper right to ensure that everything is working and data is sent correctly
