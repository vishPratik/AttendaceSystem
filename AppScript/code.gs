function doPost(e) {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Attendance");
  const response = { status: "success", message: "Attendance recorded" };

  try {
    // Validate request exists
    if (!e || !e.postData) {
      throw new Error("No data received");
    }

    const data = e.parameter;
    
    // Validate required fields
    if (!data.studentId || !data.qrData || !data.timestamp) {
      throw new Error("Missing required fields (studentId, qrData, timestamp)");
    }

    // Validate QR format
    if (!data.qrData.startsWith("ATTENDANCE:")) {
      throw new Error("Invalid QR code format");
    }

    const qrParts = data.qrData.split("|");
    if (qrParts.length < 4) {
      throw new Error("QR data missing components (Subject|Class|Lecturer|SessionID)");
    }

    // Write to sheet
    sheet.appendRow([
      new Date(), // Timestamp
      data.studentId.trim(),
      qrParts[0].replace("ATTENDANCE:", "").trim(), // Subject
      qrParts[1].trim(), // Class
      qrParts[2].trim(), // Lecturer
      qrParts[3].trim(), // Session ID
      Utilities.formatDate(new Date(), Session.getScriptTimeZone(), "yyyy-MM-dd"),
      Utilities.formatDate(new Date(), Session.getScriptTimeZone(), "HH:mm:ss"),
      "Present"
    ]);

  } catch (error) {
    response.status = "error";
    response.message = error.message;
    console.error("Error:", error.message);
  }

  return ContentService
    .createTextOutput(JSON.stringify(response))
    .setMimeType(ContentService.MimeType.JSON);
}