// create render comp.jsx 
// V 1.0  - 18.3.2009
// 	first version, no gui or anything, just the logic

// Script by Daniel Bachler to create a new parent composition containing the
// current comp as it's only layer but only the fragment that is currently set to be
// the preview range. Usefull to create new comps to add to the render queue 
// if you only want to render small fragments a large timeline

// possible future versions of this script will be released on www.danyx.com and 
// aenhancers.com

// Released under a Creative Commons 3.0 BY license, so feel free to modify
// it to your needs

{

  // function that checks whether there already is an item with the given name
  // in the given folder
  function itemWithGivenNameExists(folder, name)
  {
	  for (i = 1; i<=folder.numItems; i++)
	    if (folder.item(i).name == name)
		  return true;
      return false;
  }

  // check if  the user selected a comp
  var activeComp = app.project.activeItem;
  if(activeComp != null && activeComp instanceof CompItem) 
  {
	    // create undo group
	    app.beginUndoGroup("Make render comp");
		try
		{		
			  // create new comp name from "Rendercomp" plus the name of the active comp
			  var newCompName = "Rendercomp "+ activeComp.name ;
			  
			  // append a number and make sure the name is unique in the root folder
			  var counter = 1;
			  while (itemWithGivenNameExists(app.project.rootFolder, newCompName + counter.toString()))
			    counter++;
		      newCompName = newCompName + counter.toString();
			  
			  // store the working area start time
			  var workAreaStartTime = activeComp.workAreaStart;
			  
			  // create a new comp with the same attributes as the current comp but with a length of the work area
			  var newComp = app.project.items.addComp(newCompName, activeComp.width, activeComp.height, activeComp.pixelAspect, activeComp.workAreaDuration, activeComp.frameRate);
			  
			  // nest the active comp in this new comp and set the in point accordingly
			  newComp.layers.add(activeComp);
			  newComp.layer(1).inPoint = -workAreaStartTime;
		}
		finally
		{
			// make sure undo group gets closed even if there is a problem
			  app.endUndoGroup();
		}
  }
  else
  {
    alert("please select a composition.");
  }

}