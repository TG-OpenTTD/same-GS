class CompanyDuude {
	static cPage = [];
	static gElement = [];
	static cPoints = [];
	static cValue = [];
	static cGoal = [];
	constructor() {
		for (local i = 0; i < 21 * 5; i++) {
			cPage.push(-1);
		}
		for (local i = 0; i < 15; i++) {
			cValue.push(null);
			cPoints.push(-1);
		}
		for (local i = 0; i < 64; i++) {
			gElement.push(-1);
		}
		for (local i = 0; i < 16; i++) {
			cGoal.push(-1);
		}
	}
	function GetPageID();
	function NewCompany();
	function Init();
	function StoryUpdate();
	function StoryUpgrade();
}

function CompanyDuude::SetValue(cID, value) {
	CompanyDuude.cValue[cID] = value;
}

function CompanyDuude::AddPoints(cID, points) {
	if (cID == null) {
		return;
	}
	local value = CompanyDuude.cPoints[cID];
	if (value == -1) {
		value = 0;
		CompanyDuude.NewCompany(cID);
	}
	value += points;
	CompanyDuude.cPoints[cID] = value;
}

function CompanyDuude::RemovePoints(cID, points) {
	local value = CompanyDuude.cPoints[cID];
	if (value == -1) {
		value = 0;
		CompanyDuude.NewCompany(cID);
	}
	value -= points;
	if (value < 0) {
		value = 0;
	}
	CompanyDuude.cPoints[cID] = value;
}

function CompanyDuude::GetPageID(cID, opt) {
	if (cID > 21 || cID < 0) {
		GSLog.Error("Error: can't set pageID - Bad Value" + cID);
		return -1;
	}
	local x = cID * 5;
	if (cID == 15 || cID > 16) {
		opt = 0;
	}
	return CompanyDuude.cPage[x + opt];
}

function CompanyDuude::GetGoalID(cID) {
	if (cID > 15 || cID < 0) {
		GSLog.Error("Error: can't set goalID - Bad Value" + cID);
		return -1;
	}
	if (cID == 15 || cID > 16) {
		cID = 15;
	}
	return CompanyDuude.cGoal[cID];
}


function CompanyDuude::RemoveCompany(cID) {
	if (cID == -1) {
		return;
	}
	local x = cID * 5;
	for (local z = 0; z < 3; z++) {
		local p = CompanyDuude.GetPageID(cID, z);
		GSStoryPage.Remove(p);
		CompanyDuude.cPage[x + z] = -1;
	}
	CompanyDuude.cValue[cID] = null;
	CompanyDuude.cPoints[cID] = -1;
	GSGoal.Remove(cID);
	CompanyDuude.cGoal[cID] = null;
	CacheDuude.SetData("companyDate", cID, 0);
	GSLog.Info("Removing company #" + cID);
	local cargo_list = GSCargoList();
	foreach(cargo, _ in cargo_list) {
		local label = GSCargo.GetCargoLabel(cargo);
	}
}

function CompanyDuude::ValueReset(company) {
	CompanyDuude.cPoints[company] = 0;
}

function CompanyDuude::NewCompany(cID) {
	if (GSCompany.ResolveCompanyID(cID) == GSCompany.COMPANY_INVALID) return;
	local x = cID * 5;
	if (!GSStoryPage.IsValidStoryPage(CompanyDuude.cPage[x + 0])) {
		CompanyDuude.cPage[x + 0] = GSStoryPage.New(cID, GSText(GSText.STR_COMPANY_TITLE, cID));
	}
	local comp_txt = GSText(GSText.STR_RANK_COMPANY, GSCompany.ResolveCompanyID(cID));
	CompanyDuude.cPage[x + 1] = CompanyDuude.StoryUpdate(CompanyDuude.GetPageID(cID, 0), CompanyDuude.cPage[x + 1], comp_txt);
	local comp_txt = GSText(GSText.STR_RANK_COMPANY2, GSCompany.ResolveCompanyID(cID));
	CompanyDuude.cPage[x + 2] = CompanyDuude.StoryUpdate(CompanyDuude.GetPageID(cID, 0), CompanyDuude.cPage[x + 2], comp_txt);
	local logpage = " ";
	for (local p = 0; p < 5; p++) {
		logpage += "#" + CompanyDuude.cPage[x + p] + " ";
	}
	GSLog.Info("Added company #" + cID + " " + GSCompany.GetName(cID) + " using pages " + logpage);
	if (CacheDuude.GetData("companyDate", cID) == 0) {
		CacheDuude.SetData("companyDate", cID, GSDate.GetCurrentDate());
	}
	CompanyDuude.ValueReset(cID);
	CacheDuude.Monitoring();
}

function CompanyDuude::Question(cID) {
	if (!GSGoal.IsValidGoal(CompanyDuude.GetGoalID(15))) {
		CompanyDuude.cGoal[15] = GSGoal.New(GSCompany.COMPANY_INVALID, GSText(GSText.STR_QUESTION_RULES2, cID), GSGoal.GT_COMPANY, GSCompany.ResolveCompanyID(cID));
	} else {
		CompanyDuude.cGoal[15] = GSGoal.New(GSCompany.COMPANY_INVALID, GSText(GSText.STR_QUESTION_RULES2, cID), GSGoal.GT_COMPANY, GSCompany.ResolveCompanyID(cID));
	}
	if (GSGoal.IsValidGoal(GSCompany.ResolveCompanyID(cID))) {
		CompanyDuude.cGoal[cID] = GSGoal.New(cID, GSText(GSText.STR_QUESTION_RULES2, cID), GSGoal.GT_STORY_PAGE, CompanyDuude.GetPageID(cID, 0));
	}
	if (GSGame.IsMultiplayer() || !GSGame.IsMultiplayer()) {
			GSGoal.Question(CompanyDuude.cGoal[cID], GSCompany.ResolveCompanyID(cID), GSText(GSText.STR_QUESTION_RULES1), GSGoal.QT_INFORMATION, GSGoal.BUTTON_ACCEPT + GSGoal.BUTTON_DECLINE);
	}
	GSLog.Warning("Company #" + cID + " " + GSCompany.GetName(cID) + " asked about rules");
}

function CompanyDuude::Init() {
	if (!GSStoryPage.IsValidStoryPage(CompanyDuude.GetPageID(15, 0))) {
		CompanyDuude.cPage[15 * 5] = GSStoryPage.New(GSCompany.COMPANY_INVALID, GSText(GSText.STR_WELCOME_TITLE));
	}
	local serverName = GSController.GetSetting("serverName");
	if (serverName == 1) {
		serverName = GSText(GSText.STR_WELCOME_WELCOME, GSText(GSText.STR_SERVER_VANILLA), GSText(GSText.STR_RED), GSText(GSText.STR_IMPORTANT), GSText(GSText.STR_YELLOW), GSText(GSText.STR_SERVER_VANILLA_AWARE));
	} else if (serverName == 2) {
		serverName = GSText(GSText.STR_WELCOME_WELCOME, GSText(GSText.STR_SERVER_WELCOME), GSText(GSText.STR_RED), GSText(GSText.STR_IMPORTANT), GSText(GSText.STR_YELLOW), GSText(GSText.STR_SERVER_WELCOME_AWARE));
	} else if (serverName == 3) {
		serverName = GSText(GSText.STR_WELCOME_WELCOME, GSText(GSText.STR_SERVER_PUBLIC), GSText(GSText.STR_RED), GSText(GSText.STR_IMPORTANT), GSText(GSText.STR_YELLOW), GSText(GSText.STR_SERVER_PUBLIC_AWARE));
	} else {
		serverName = GSText(GSText.STR_WELCOME_WELCOME, GSText(GSText.STR_SERVER_DEFAULT), GSText(GSText.STR_RED), GSText(GSText.STR_IMPORTANT), GSText(GSText.STR_YELLOW), GSText(GSText.STR_SERVER_DEFAULT_AWARE));
	}
	CompanyDuude.cPage[15 * 5 + 1] = CompanyDuude.StoryUpdate(CompanyDuude.GetPageID(15, 0), CompanyDuude.cPage[15 * 5 + 1], GSText(GSText.STR_BLACK, serverName, GSText(GSText.STR_ORANGE_COL), GSText(GSText.STR_PLEASE), GSText(GSText.STR_YELLOW_COL), GSText(GSText.STR_WELCOME_RULES)));
	local check = GSText(GSText.STR_LTBLUE, GSText(GSText.STR_CHECK), GSText(GSText.STR_BLACK));
	local arrow = GSText(GSText.STR_YELLOW_COL, GSText(GSText.STR_ARROW));
	local srv = GSText(GSText.STR_BLANK, GSText(GSText.STR_ORANGE_COL), GSText(GSText.STR_SERVERS), GSText(GSText.STR_BLACK), GSText(GSText.STR_WELCOME_SERV));
	local wlcm_txt = GSText(GSText.STR_ORANGE_COL, GSText(GSText.STR_TGOTTD), GSText(GSText.STR_BLACK), GSText(GSText.STR_WELCOME_TEXT1), check, GSText(GSText.STR_WELCOME_TEXT2), check, GSText(GSText.STR_WELCOME_TEXT3), check, GSText(GSText.STR_WELCOME_TEXT4), check, GSText(GSText.STR_BLANK), srv, arrow, GSText(GSText.STR_SERVER_S1), arrow, GSText(GSText.STR_SERVER_S2), arrow, GSText(GSText.STR_SERVER_S3));
	CompanyDuude.cPage[15 * 5 + 2] = CompanyDuude.StoryUpdate(CompanyDuude.GetPageID(15, 0), CompanyDuude.cPage[15 * 5 + 2], GSText(GSText.STR_BLANK, wlcm_txt));
	if (!GSStoryPage.IsValidStoryPage(CompanyDuude.GetPageID(16, 0))) {
		CompanyDuude.cPage[16 * 5] = GSStoryPage.New(GSCompany.COMPANY_INVALID, GSText(GSText.STR_RULES_TITLE));
	}
	local triple_hash = GSText(GSText.STR_BLACK, GSText(GSText.STR_3HASH), GSText(GSText.STR_ORANGE_COL));
	local single_hash = GSText(GSText.STR_BLACK, GSText(GSText.STR_1HASH), GSText(GSText.STR_ORANGE_COL));
	CompanyDuude.cPage[16 * 5 + 1] = CompanyDuude.StoryUpdate(CompanyDuude.GetPageID(16, 0), CompanyDuude.cPage[16 * 5 + 1], GSText(GSText.STR_BLANK, triple_hash, GSText(GSText.STR_RULES_RULES), single_hash, GSText(GSText.STR_RULES_STEALING), single_hash, GSText(GSText.STR_RULES_TELEPORT)));
	CompanyDuude.cPage[16 * 5 + 2] = CompanyDuude.StoryUpdate(CompanyDuude.GetPageID(16, 0), CompanyDuude.cPage[16 * 5 + 2], GSText(GSText.STR_BLANK, single_hash, GSText(GSText.STR_RULES_GRIDS), single_hash, GSText(GSText.STR_RULES_CENTRAL), single_hash, GSText(GSText.STR_RULES_FORBIDS)));
	if (!GSStoryPage.IsValidStoryPage(CompanyDuude.GetPageID(17, 0))) {
		CompanyDuude.cPage[17 * 5] = GSStoryPage.New(GSCompany.COMPANY_INVALID, GSText(GSText.STR_SETTINGS_TITLE));
	}
	local starting_year = 0;
	if (GSGameSettings.IsValid("game_creation.starting_year")) {
		starting_year = GSGameSettings.GetValue("game_creation.starting_year");
	}
	local restart_game_year = 0;
	local game_duration = 0;
	if (GSGameSettings.IsValid("network.restart_game_year")) {
		if (GSGameSettings.GetValue("network.restart_game_year") != 0) {
			restart_game_year = GSGameSettings.GetValue("network.restart_game_year");
			game_duration = GSText(GSText.STR_SETTINGS_SET02, restart_game_year, restart_game_year - starting_year);
		} else {
			game_duration = GSText(GSText.STR_SETTINGS_SET03);
		}
	}
	local str_game_duration = GSText(GSText.STR_BLACK, single_hash, GSText(GSText.STR_SETTINGS_SET01), starting_year, game_duration);
	local str_breakdowns = GSText(GSText.STR_BLACK, single_hash, GSText(GSText.STR_SETTINGS_SET04));
	local str_twoway = GSText(GSText.STR_BLACK, single_hash, GSText(GSText.STR_SETTINGS_SET05));
	local str_inflation = GSText(GSText.STR_BLACK, single_hash, GSText(GSText.STR_SETTINGS_SET06));
	local str_expire = GSText(GSText.STR_BLACK, single_hash, GSText(GSText.STR_SETTINGS_SET07));
	local str_90_turns = GSText(GSText.STR_BLACK, single_hash, GSText(GSText.STR_SETTINGS_SET08));
	local max_bridge_length = 0;
	if (GSGameSettings.IsValid("construction.max_bridge_length")) {
		max_bridge_length = GSGameSettings.GetValue("construction.max_bridge_length");
	}
	local str_bridge_length = GSText(GSText.STR_BLACK, single_hash, GSText(GSText.STR_SETTINGS_SET09), max_bridge_length);
	local max_tunnel_length = 0;
	if (GSGameSettings.IsValid("construction.max_tunnel_length")) {
		max_tunnel_length = GSGameSettings.GetValue("construction.max_tunnel_length");
	}
	local str_tunnel_length = GSText(GSText.STR_BLACK, single_hash, GSText(GSText.STR_SETTINGS_SET10), max_tunnel_length);
	local station_spread = 0;
	if (GSGameSettings.IsValid("station.station_spread")) {
		station_spread = GSGameSettings.GetValue("station.station_spread");
	}
	local str_station_spread = GSText(GSText.STR_BLACK, single_hash, GSText(GSText.STR_SETTINGS_SET11), station_spread);
	local max_loan = 0;
	if (GSGameSettings.IsValid("difficulty.max_loan")) {
		max_loan = GSGameSettings.GetValue("difficulty.max_loan");
	}
	local str_loan = GSText(GSText.STR_BLACK, single_hash, GSText(GSText.STR_SETTINGS_SET12), max_loan);
	local max_trains = 0;
	if (GSGameSettings.IsValid("vehicle.max_trains")) {
		max_trains = GSGameSettings.GetValue("vehicle.max_trains")
	}
	local str_trains = GSText(GSText.STR_BLACK, single_hash, GSText(GSText.STR_SETTINGS_SET13), max_trains);
	local max_roadveh = 0;
	if (GSGameSettings.IsValid("vehicle.max_roadveh")) {
		max_roadveh = GSGameSettings.GetValue("vehicle.max_roadveh")
	}
	local str_roadveh = GSText(GSText.STR_BLACK, single_hash, GSText(GSText.STR_SETTINGS_SET14), max_roadveh);
	local max_ships = 0;
	if (GSGameSettings.IsValid("vehicle.max_ships")) {
		max_ships = GSGameSettings.GetValue("vehicle.max_ships")
	}
	local str_ships = GSText(GSText.STR_BLACK, single_hash, GSText(GSText.STR_SETTINGS_SET15), max_ships);
	local max_aircraft = 0;
	if (GSGameSettings.IsValid("vehicle.max_aircraft")) {
		max_aircraft = GSGameSettings.GetValue("vehicle.max_aircraft")
	}
	local str_aircrafts = GSText(GSText.STR_BLACK, single_hash, GSText(GSText.STR_SETTINGS_SET16), max_aircraft);
	CompanyDuude.cPage[17 * 5 + 1] = CompanyDuude.StoryUpdate(CompanyDuude.GetPageID(17, 0), CompanyDuude.cPage[17 * 5 + 1], GSText(GSText.STR_WHITE, str_game_duration, str_breakdowns, str_twoway));
	CompanyDuude.cPage[17 * 5 + 2] = CompanyDuude.StoryUpdate(CompanyDuude.GetPageID(17, 0), CompanyDuude.cPage[17 * 5 + 2], GSText(GSText.STR_WHITE, str_inflation, str_90_turns));
	CompanyDuude.cPage[17 * 5 + 3] = CompanyDuude.StoryUpdate(CompanyDuude.GetPageID(17, 0), CompanyDuude.cPage[17 * 5 + 3], GSText(GSText.STR_WHITE, str_bridge_length, str_tunnel_length));
	CompanyDuude.cPage[17 * 5 + 4] = CompanyDuude.StoryUpdate(CompanyDuude.GetPageID(17, 0), CompanyDuude.cPage[17 * 5 + 4], GSText(GSText.STR_WHITE, str_loan, str_station_spread, str_trains));
	CompanyDuude.cPage[17 * 5 + 5] = CompanyDuude.StoryUpdate(CompanyDuude.GetPageID(17, 0), CompanyDuude.cPage[17 * 5 + 5], GSText(GSText.STR_WHITE, str_roadveh, str_ships, str_aircrafts));
	if (!GSStoryPage.IsValidStoryPage(CompanyDuude.GetPageID(18, 0))) {
		CompanyDuude.cPage[18 * 5] = GSStoryPage.New(GSCompany.COMPANY_INVALID, GSText(GSText.STR_STUFF_TITLE));
	}
	CompanyDuude.cPage[18 * 5 + 1] = CompanyDuude.StoryUpdate(CompanyDuude.GetPageID(18, 0), CompanyDuude.cPage[18 * 5 + 1], GSText(GSText.STR_STUFF_SET1, GSText(GSText.STR_STUFF_SET2), GSText(GSText.STR_STUFF_SET3)));
	CompanyDuude.cPage[18 * 5 + 2] = CompanyDuude.StoryUpdate(CompanyDuude.GetPageID(18, 0), CompanyDuude.cPage[18 * 5 + 2], GSText(GSText.STR_STUFF_SET4, GSText(GSText.STR_STUFF_SET5), GSText(GSText.STR_STUFF_SET6)));
	if (!GSStoryPage.IsValidStoryPage(CompanyDuude.GetPageID(19, 0))) {
		CompanyDuude.cPage[19 * 5] = GSStoryPage.New(GSCompany.COMPANY_INVALID, GSText(GSText.STR_LINKS_TITLE));
	}
	CompanyDuude.cPage[19 * 5 + 1] = CompanyDuude.StoryUpdate(CompanyDuude.GetPageID(19, 0), CompanyDuude.cPage[19 * 5 + 1], GSText(GSText.STR_LINK_PRE));
	CompanyDuude.cPage[19 * 5 + 2] = CompanyDuude.StoryUpdate(CompanyDuude.GetPageID(19, 0), CompanyDuude.cPage[19 * 5 + 2], GSText(GSText.STR_LINK_TELEGRAM, GSText(GSText.STR_LINK_DISCORD), GSText(GSText.STR_LINK_WEB)));
	// if (!GSStoryPage.IsValidStoryPage(CompanyDuude.GetPageID(20, 0))) {
	//     CompanyDuude.cPage[20 * 3] = GSStoryPage.New(GSCompany.COMPANY_INVALID, GSText(GSText.STR_GOALS_TITLE));
	// }
	// CompanyDuude.cPage[20 *3 + 1] = CompanyDuude.StoryUpdate(CompanyDuude.GetPageID(20, 0), CompanyDuude.cPage[20 * 3 +1], GSText(GSText.STR_GOALS_PRE));
	// CompanyDuude.cPage[20 *3 + 2] = CompanyDuude.StoryUpdate(CompanyDuude.GetPageID(20, 0), CompanyDuude.cPage[20 * 3 +2], GSText(GSText.STR_GOALS_FIRST));
	// if (!GSGoal.IsValidGoal(1)) {
	// 	CompanyDuude.cGoal[1] = GSGoal.New(GSCompany.COMPANY_INVALID, "I READ THE RULES", GSGoal.GT_STORY_PAGE, CompanyDuude.GetPageID(16, 0));
	// }
	GSStoryPage.SetDate(CompanyDuude.GetPageID(15, 0), GSDate.DATE_INVALID);
	GSStoryPage.SetDate(CompanyDuude.GetPageID(16, 0), GSDate.DATE_INVALID);
	GSStoryPage.SetDate(CompanyDuude.GetPageID(17, 0), GSDate.DATE_INVALID);
	GSStoryPage.SetDate(CompanyDuude.GetPageID(18, 0), GSDate.DATE_INVALID);
	GSStoryPage.SetDate(CompanyDuude.GetPageID(19, 0), GSDate.DATE_INVALID);
	// GSStoryPage.SetDate(CompanyDuude.GetPageID(20, 0), GSDate.DATE_INVALID);
	CompanyDuude.StoryUpgrade();
}

function CompanyDuude::StoryUpdate(pID, eID, txt, type = GSStoryPage.SPET_TEXT, ref = 0) {
	if (!GSStoryPage.IsValidStoryPageElement(eID)) {
		eID = GSStoryPage.NewElement(pID, type, 0, "TEXT");
		if (eID == GSStoryPage.STORY_PAGE_ELEMENT_INVALID) {
			return -1;
		}
	}
	GSStoryPage.UpdateElement(eID, ref, txt);
	return eID;
}

function CompanyDuude::StoryUpgrade() {
	local rank = GSList();
	for (local i = 0; i < 15; i++) {
		rank.AddItem(i, CompanyDuude.cPoints[i]);
	}
	rank.Sort(GSList.SORT_BY_VALUE, GSList.SORT_DESCENDING);
	local counter = 0;
	local draw = -1;
	local result = [];
	local points = -1;
	foreach(cID, top in rank) {
		if (GSCompany.ResolveCompanyID(cID) == GSCompany.COMPANY_INVALID) {
			points = -1;
			CompanyDuude.cPoints[cID] = -1;
		} else {
			if (top == -1) {
				points = 0;
				CompanyDuude.cPoints[cID] = 0;
				CompanyDuude.NewCompany(cID);
			} else {
				points = top;
			}
		}
		if (points != draw && points != -1) {
			counter++;
			draw = points;
		}
		local res = null;
		switch (counter) {
			case 1:
				res = GSText(GSText.STR_GREEN);
				break;
			case 2:
				res = GSText(GSText.STR_YELLOW);
				break;
			case 3:
				res = GSText(GSText.STR_ORANGE);
				break;
			default:
				res = GSText(GSText.STR_RED);
		}
		if (points == -1) {
			res = " ";
		} else {
			res.AddParam(GSText(GSText.STR_RANK));
			res.AddParam(counter);
			res.AddParam(cID);
			res.AddParam(points);
		}
		result.push(res);
	}
	for (local i = 0; i < result.len(); i++) {
		GSStoryPage.UpdateElement(CompanyDuude.gElement[i], 0, result[i]);
	}
}