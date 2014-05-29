//
//  ViewController.m
//  ZaHunter
//
//  Created by Ryan Tiltz on 5/29/14.
//  Copyright (c) 2014 Ryan Tiltz. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>
#import <MapKit/MapKit.h>

@interface ViewController () <CLLocationManagerDelegate, UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate>

@property CLLocationManager *locationManager;
@property CLLocation *currentLocation;
@property CLPlacemark *currentAddress;
@property NSArray *pizzaPlaces;
@property CLLocation *location;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self requestCurrentLocation];
}

-(void)requestCurrentLocation
{
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

-(void)searchForPizza
{
    MKLocalSearchRequest *searchRequest = [MKLocalSearchRequest new];

    searchRequest.region = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, 30000, 30000);

    searchRequest.naturalLanguageQuery = @"pizza";

    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:searchRequest];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        self.pizzaPlaces = response.mapItems;
        self.pizzaPlaces = [self.pizzaPlaces sortedArrayUsingComparator:^NSComparisonResult(MKMapItem *obj1, MKMapItem *obj2)
                       {
                           return [self.currentLocation distanceFromLocation:obj1.placemark.location] -
                           [self.currentLocation distanceFromLocation:obj2.placemark.location];
                       }];
        [self.myTableView reloadData];

    }];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *phoneLocation in locations) {
        if (phoneLocation.verticalAccuracy > 500 || phoneLocation.horizontalAccuracy > 500)
            continue;

        [self.locationManager stopUpdatingLocation];
        self.currentLocation = phoneLocation;
        [self searchForPizza];
        break;
    }
}

-(void)showDirectionsTo:(MKMapItem*)destinationItem
{
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = destinationItem;
    MKDirections *directions = [[MKDirections alloc]initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
    }];
}

-(UITableViewCell *)tableView:(UITableView *)myTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [myTableView dequeueReusableCellWithIdentifier:@"PizzaID"];

    CLPlacemark *place = [self.pizzaPlaces[indexPath.row] placemark];
    cell.textLabel.text = place.name;

    double distance = [place.location distanceFromLocation:self.currentLocation];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%f", distance];

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}
@end
