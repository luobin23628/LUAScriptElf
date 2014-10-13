
// Logos by Dustin Howett
// See http://iphonedevwiki.net/index.php/Logos


%hook SpringBoard

- (void)volumeChanged:(GSEventRef)gsEvent
{
	%log;
    
    switch (GSEventGetType(gsEvent)) {
		case kGSEventVolumeUpButtonDown: {

			break;
		}
		case kGSEventVolumeUpButtonUp: {
			CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();

			break;
		}
		case kGSEventVolumeDownButtonDown: {

			break;
		}
		case kGSEventVolumeDownButtonUp: {

			break;
		}
		default:
			break;
	}

	%orig(gsEvent);
}


%end
