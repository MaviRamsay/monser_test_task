CMD:takemoney(playerid, const params[])
{
	if (!IsPlayerAdmin(playerid)) return 0;

	extract params -> new iMoney; else return SendClientMessage(playerid, -1, !"�������: /takemoney [�����]");

	if (iMoney <= 0) {
		return SendClientMessage(playerid, -1, !"������� �������� �����");
	}

	aPlayerInfo[playerid][pMoney] += iMoney;
	GivePlayerMoney(playerid, iMoney);

	SendClientMessage(playerid, -1, !"������ ����������");

	return 1;
}