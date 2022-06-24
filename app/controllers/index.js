import TiWidgetKit from 'ti.widgetkit';

const GROUP_IDENTIFIER = 'group.io.tidev.sample-widgetkit';
const USER_DEFAULTS_IDENTIFIER = 'kSampleAppMyData';

function saveData() {
	const payload = { title: 'My Title', count: 1337 };

	// 1) Save data
	const userDefaults = Ti.App.iOS.createUserDefaults({ suiteName: GROUP_IDENTIFIER });
	userDefaults.setObject(USER_DEFAULTS_IDENTIFIER, payload);

	// 2) Refresh widget UI
	TiWidgetKit.reloadAllTimelines();

	// NOTE: The widget will show the "Default" title until your app groups are properly linked to your
	// main app and extension. Please read this article very carefully before jumping into more detail:
	// https://developer.apple.com/documentation/widgetkit/creating-a-widget-extension

	alert('Done!');
}

$.getView().open();
