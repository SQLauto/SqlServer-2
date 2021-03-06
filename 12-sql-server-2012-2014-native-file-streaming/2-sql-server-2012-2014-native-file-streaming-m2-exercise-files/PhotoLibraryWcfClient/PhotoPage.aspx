﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PhotoPage.aspx.cs" Inherits="PhotoLibraryWcfClient.PhotoPage" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
	<title>WCF FILESTREAM Demo</title>
	<style>
		body {
			font-family: 'Segoe UI';
			font-size: 12pt;
		}

		input {
			font-family: 'Segoe UI';
			font-size: 12pt;
		}
	</style>
</head>
<body>
	<form id="form1" runat="server">
		<div style="border: 1px solid gray; padding: 8px; width: 500px; margin-top: 16px;">
			<b>Select Photo</b>
			<table>
				<tr>
					<td>Photo ID:</td>
					<td>
						<asp:TextBox runat="server" ID="loadPhotoIdTextBox" Width="60px" /></td>
				</tr>
				<tr>
					<td>
						<asp:LinkButton runat="server" ID="loadLinkButton" Text="Load" OnClick="loadLinkButton_Click" />
					</td>
				</tr>
				<tr>
					<td colspan="2" style="padding-top: 16px;">
						<asp:Image runat="server" ID="photoImage" Style="min-width: 100px; max-width: 400px;" /><br />
					</td>
				</tr>
			</table>
		</div>
	</form>
</body>
</html>
