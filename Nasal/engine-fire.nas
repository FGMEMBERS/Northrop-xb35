settimer(func {

  # Add listener for engine fire
  setlistener("controls/engines/engine/on-fire", func(n) {
      wildfire.ignite;
  });

}, 0);

var fire_dialog = gui.Dialog.new("/sim/gui/dialogs/xb35/status/dialog","Aircraft/Northrop-xb35/Dialogs/malfunctions-dialog.xml");
