// Copyright 2012 ESRI
//
// All rights reserved under the copyright laws of the United States
// and applicable international laws, treaties, and conventions.
//
// You may freely redistribute and use this sample code, with or
// without modification, provided you include the original copyright
// notice and use restrictions.
//
// See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
//

#import "MainViewController.h"

@implementation MainViewController

@synthesize mapView=_mapView;
@synthesize infoButton=_infoButton;
@synthesize legendDataSource=_legendDataSource;
@synthesize legendViewController=_legendViewController;
@synthesize popOverController=_popOverController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"2010 total SNAP Benefits";

    // Register for geometry changed notifications
    // Calls method that adds the layer to the legend each time layer is loaded
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToLayerLoaded:) name:AGSLayerDidLoadNotification object:nil];
	
	/*NSURL *mapUrl = [NSURL URLWithString:@"http://services.arcgisonline.com/ArcGIS/rest/services/Specialty/Soil_Survey_Map/MapServer"];
	AGSTiledMapServiceLayer *tiledLyr = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:mapUrl];
	[self.mapView addMapLayer:tiledLyr withName:@"Tiled Layer"];
     */
    
    NSURL *mapUrl = [NSURL URLWithString:@"http://gis2.ers.usda.gov/ArcGIS/rest/services/Background_Cache/MapServer"];
	AGSTiledMapServiceLayer *tiledLyr = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:mapUrl];
	[self.mapView addMapLayer:tiledLyr withName:@"Background"];
    
    // states map
    NSURL *mapUrl3 = [NSURL URLWithString:@"http://gis2.ers.usda.gov/ArcGIS/rest/services/Reference2/MapServer"];
	AGSDynamicMapServiceLayer *dynamicLyr2 = [AGSDynamicMapServiceLayer dynamicMapServiceLayerWithURL:mapUrl3];
	[self.mapView addMapLayer:dynamicLyr2 withName:@"Reference"];
        
    // add the dynamic layer
     NSURL* url = [NSURL URLWithString: @"http://gis2.ers.usda.gov/ArcGIS/rest/services/snap_Benefits/MapServer"];
     NSError *error = nil;
     AGSMapServiceInfo *info = [AGSMapServiceInfo mapServiceInfoWithURL:url error:&error];
     
     //inspect or modify the info object if you want
     //...;
     
     AGSDynamicMapServiceLayer* layer = [AGSDynamicMapServiceLayer dynamicMapServiceLayerWithMapServiceInfo: info];
    
    // specifies which layer(s) are displayed on the map - this is different from what's displayed in the legend; without this code, nothing is displayed
    if(layer.loaded)
    { 
       // layer.visibleLayers= [NSArray arrayWithObjects:[NSNumber numberWithInt:0],[NSNumber numberWithInt:1], nil];
        
        // only show the Xth layer
        layer.visibleLayers= [NSArray arrayWithObjects:[NSNumber numberWithInt:0], nil];
        layer.opacity = .8;
    }
    
    [self.mapView addMapLayer:layer withName:@"Snap Benefits"];
    
    //Zooming to an initial envelope with the specified spatial reference of the map.
	AGSSpatialReference *sr = [AGSSpatialReference webMercatorSpatialReference];
	AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:-14314526
                                                ymin:2616367
                                                xmax:-7186578
                                                ymax:6962565
									spatialReference:sr];
	[self.mapView zoomToEnvelope:env animated:YES];

	//A data source that will hold the legend items
	self.legendDataSource = [[LegendDataSource alloc] init];
	
	//Initialize the legend view controller
	//This will be displayed when user clicks on the info button

	self.legendViewController = [[LegendViewController alloc] initWithNibName:@"LegendViewController" bundle:nil];
	self.legendViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
	self.legendViewController.legendDataSource = self.legendDataSource;
	
	if([[AGSDevice currentDevice] isIPad]){
        
		self.popOverController = [[UIPopoverController alloc]
								  initWithContentViewController:self.legendViewController];
		[self.popOverController setPopoverContentSize:CGSizeMake(250, 500)];
		self.popOverController.passthroughViews = [NSArray arrayWithObject:self.view];
		self.legendViewController.popOverController = self.popOverController;
	}
}

#pragma mark -
#pragma mark AGSMapViewDelegate

- (void)respondToLayerLoaded:(NSNotification*)notification {
    
	//Add legend for each layer added to the map
	[self.legendDataSource addLegendForLayer:(AGSLayer *)notification.object];
}

- (void) mapViewDidLoad:(AGSMapView *) mapView {
    NSLog(@"loaded mapView");
}


- (IBAction) presentLegendViewController: (id) sender{
	//If iPad, show legend in the PopOver, else transition to the separate view controller
	if([[AGSDevice currentDevice] isIPad]){
		[_popOverController presentPopoverFromRect:self.infoButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES ];
		
	}else {
		[self presentModalViewController:self.legendViewController animated:YES];
	}

}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	//Re-show popOver to position it correctly after orientation change
	if([[AGSDevice currentDevice] isIPad] && self.popOverController.popoverVisible) {
		[self.popOverController dismissPopoverAnimated:NO];
		[self.popOverController presentPopoverFromRect:self.infoButton.frame 
												inView:self.view 
							  permittedArrowDirections:UIPopoverArrowDirectionUp 
											  animated:YES ];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.mapView = nil;
	self.infoButton = nil;
	self.legendDataSource = nil;
	self.legendViewController = nil;
	if([[AGSDevice currentDevice] isIPad])
		self.popOverController = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AGSLayerDidLoadNotification object:nil];
}



@end
