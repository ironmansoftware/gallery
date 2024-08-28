# System APIs

## Overview

This module provides API features focused on system information. This includes information about the system, drives, network and processes. 

## Features

This module includes [licensed](https://powershelluniversal.com/pricing) features. 

### Endpoints

- `/system` - Returns information about the system. 
- `/system/drive` - Returns information about the drives on the system.
- `/system/network` - Returns information about the network interfaces on the system.
- `/system/process` - Returns information about the processes running on the system.

### Endpoint Documentation 

An endpoint documentation file is provided at `/system/docs` which provides detailed information about the endpoints and their usage.

### Roles 

- `System API Reader` - Allows the user to read system information.

The `Administrator` user also has access to these endpoints.