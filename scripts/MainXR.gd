extends XROrigin3D

func _ready():
	var viewport := get_viewport()
	viewport.use_xr = true
	viewport.transparent_bg = true

	var xr := XRServer.find_interface("OpenXR")
	if xr:
		print("XRDBG: OpenXR found")
		xr.initialize()
		print("XRDBG: XR initialized =", xr.is_initialized())
		print("XRDBG: Passthrough supported =", xr.is_passthrough_supported())

		if xr.is_passthrough_supported():
			xr.start_passthrough()
			print("XRDBG: Passthrough started")

	print("XRDBG: viewport.use_xr =", viewport.use_xr)
	print("XRDBG: viewport.transparent_bg =", viewport.transparent_bg)
