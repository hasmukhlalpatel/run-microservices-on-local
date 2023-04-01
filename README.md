# Run Microservices on local/dev machine
This repo will demonstrate how to run and debug frontend and backend event driven microservices on local/Dev machine with [Tye](https://github.com/dotnet/tye/blob/main/docs/tutorials/hello-tye/00_run_locally.md) to run a multi-project application. 
If you haven't installed tye, follow the [Getting Started Instructions](https://github.com/dotnet/tye/blob/main/docs/getting_started.md) to install tye.

### Tips
- How to use [`tye run`](https://github.com/dotnet/tye/blob/main/docs/reference/commandline/tye-run.md)?
- How to access tye [Tye Dashboard](http://127.0.0.1:8000/) after `try run`?

## Required proejcts
* [Azure EventGrid Simulator (Run on local)](https://github.com/hasulab/Azure.EventGrid.Simulator.Sample)
	```
	git clone https://github.com/hasulab/Azure.EventGrid.Simulator.Sample.git
	```
	
	You will need a self signed certificate to run Azure EventGrid Simulator. Please check appsettings. 
	
	#### Tips
	- How to Generate a [self-signed certificate using PowerShell script](https://gist.github.com/hasmukhlalpatel/ed46bc73c7da708daafe3e566ee8f8d2)
	- How to access [Azure EventGrid Simulator homepage](https://localhost:5002/) after `try run`?

* [Azure KeyVault Simulator (Run on local)](https://github.com/hasulab/Azure.KeyVault.Simulator.Sample)
	```
	git clone https://github.com/hasulab/Azure.KeyVault.Simulator.Sample.git
	```

	#### Tips
	- How to access [Azure KeyVault Simulator homepage](https://localhost:5006/) after `try run`?
