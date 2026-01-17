import TiWidgetKit from 'ti.widgetkit';

const GROUP_IDENTIFIER = 'group.io.tidev.sample-widgetkit';
const USER_DEFAULTS_IDENTIFIER = 'kSampleAppMyData';

const userDefaults = Ti.App.iOS.createUserDefaults({ suiteName: GROUP_IDENTIFIER });

function onWindowFocus() {
	refreshUI();
}

function refreshUI() {
	const data = userDefaults.getObject(USER_DEFAULTS_IDENTIFIER);
	if (!data) {
		$.warning.text = 'No App Group configured: Setup your provisioning profiles and app group first.';
		return;
	} else {
		$.warning.text = '';
	}

	$.title.text = data.title;
	$.count.text = `${data.count}`;
}

function saveData() {
	const data = userDefaults.getObject(USER_DEFAULTS_IDENTIFIER);
	const payload = { title: data.title, count: data.count + 1 };

	// 1) Save data
	userDefaults.setObject(USER_DEFAULTS_IDENTIFIER, payload);

	// 2) Refresh widget UI
	TiWidgetKit.reloadAllTimelines();
	refreshUI();

	// NOTE: Please read this article very carefully before jumping into more detail:
	// https://developer.apple.com/documentation/widgetkit/creating-a-widget-extension
}

$.getView().open();
