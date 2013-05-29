#import <EventKit/EventKit.h>
#include <stdio.h>
#include <unistd.h>

BOOL
isValidDate(const char *dt)
{
    return (strlen(dt) == 10 && dt[4] == '-' && dt[7] == '-');
}

void
usage(const char *progname)
{
    printf("Usage: %s [-s <startDate> [-e <endDate>]] -c <calendarName>\n", progname);
    printf(" The dates are specified as YYYY-MM-DD\n");
}

int
main(int argc, char **argv)
{
    const char *startDateStr = NULL;
    const char *endDateStr = NULL;
    const char *calendarNameStr = NULL;
     
    int c;

    opterr = 0;

    while ((c = getopt (argc, argv, "hs:e:c:")) != -1) {
        switch (c) {
            case 'h':
                usage(argv[0]);
                return 0;

            case 's':
                startDateStr = optarg;
                break;
            case 'e':
                endDateStr = optarg;
                break;
            case 'c':
                calendarNameStr = optarg;
                break;
            default:
                usage(argv[0]);
                return 1;
        }
    }

    if (calendarNameStr == NULL) {
        printf("Error: Must specify the calendar name\n");
        usage(argv[0]);
        return 1;
    }

    if (startDateStr != NULL && !isValidDate(startDateStr)) {
        printf("Error: The specified start date looks invalid\n");
        usage(argv[0]);
        return 1;
    }

    if (endDateStr != NULL && !isValidDate(endDateStr)) {
        printf("Error: The specified end date looks invalid\n");
        usage(argv[0]);
        return 1;
    }

    NSString *calendarName = [NSString stringWithUTF8String:calendarNameStr];
    EKEventStore *eventStore = [[EKEventStore alloc] initWithAccessToEntityTypes:EKEntityTypeEvent];
    EKCalendar *selectedCalendar = nil;
    for (EKCalendar *cal in [eventStore calendarsForEntityType:EKEntityTypeEvent]) {
        if ([[cal title] isEqualToString:calendarName]) {
            selectedCalendar = cal;
            break;
        }
    }
    if (selectedCalendar == nil) {
        printf("Error: Couldn't get access to Pomodoro calendar!\n");

        printf("The calendars available are:\n");
        for (EKCalendar *cal in [eventStore calendarsForEntityType:EKEntityTypeEvent]) {
            printf("%s\n", [[cal title] UTF8String]);
        }
        return 1;
    }

    NSDate *startDate = [NSDate date];
    if (startDateStr != nil) {
        startDate = [NSDate dateWithString:[NSString stringWithFormat:@"%s 00:00:00 +0000", startDateStr]];
    }
    
    // endDate is 1 day = 60*60*24 seconds = 86400 seconds from startDate
    NSDate *endDate = [NSDate dateWithTimeInterval:86400 sinceDate:startDate];
    if (endDateStr != nil) {
        endDate = [NSDate dateWithString:[NSString stringWithFormat:@"%s 23:59:59 +0000", endDateStr]];
    }
    
    // Create the predicate. Pass it the default calendar.
    NSArray *calendarArray = [NSArray arrayWithObject:selectedCalendar];
    NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:startDate endDate:endDate 
                                                               calendars:calendarArray]; 
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];

    // Fetch all events that match the predicate.
    NSArray *events = [eventStore eventsMatchingPredicate:predicate];
    for (EKEvent *event in events) {
        NSString *start = @"";
        NSString *end = @"";
        
        if ([event startDate]) {
            start = [dateFormatter stringFromDate:[event startDate]];
        }
        if ([event endDate]) {
            end = [dateFormatter stringFromDate:[event endDate]];
        }
        printf("%s\t%s\t%s\n", [[event title] UTF8String], [start UTF8String], [end UTF8String]);
    }

    [eventStore release];
    [dateFormatter release];

    return 0;
}
