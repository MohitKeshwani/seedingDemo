import { LightningElement, track } from 'lwc';
import { NotificationsUtilities } from 'c/utilities';
import sheetjs from "@salesforce/resourceUrl/sheetjs";
import { loadScript } from "lightning/platformResourceLoader";
import { initiateSeedingProcess } from './downloadSheetFileWittMutipleTabClientService';
import { STATUS_MESSAGES } from 'c/constants';

export default class DownloadSheetFileWithMultipleTab extends LightningElement {

  //Read-Only and Immutable Properties belongs to Scope Review component
  @track props = {
    TITLE_CATALOG_SEEDING_DATA_WIZARD: 'Download Sheet With Multiple Tabs',
    acceptedFormats: [".xls", ".xlsx"],
  };

  @track state = {
    selectedFiles: [],
    seedingDetails: {},
    csvDataResponse: [],
    seedingFileType: "",
    sheetsName : [],
  };

  get selectedFileName() {
    return this.state.selectedFiles ? this.state.selectedFiles[0].name : "";
  }
  
  connectedCallback() {
    Promise.all([loadScript(this, sheetjs)]).then(() => {
      // eslint-disable-next-line no-undef
      XLS = XLSX;
    });
  }

  handleSelectedFiles(event) {
    this.state.selectedFiles = event.detail.files;
  }
  

  startSeedingProcess() {
    let { state } = this;
    if (state.selectedFiles.length > 0) {
      this.convertExcelFileToJSON(state.selectedFiles[0]);
    } else {
        NotificationsUtilities.showToastMessageNotification(
          STATUS_MESSAGES.STATUS_WARNING_LOWERCASE,
          'Please select file through which you want to insert the data into org.',
          STATUS_MESSAGES.STATUS_WARNING_LOWERCASE,
        );
    }
  }
  
  convertExcelFileToJSON(file) {

    var reader = new FileReader();
    reader.onload = (event) => {
      var data = event.target.result;
      const workbook = XLS.read(data, {
        type: "binary",
      });

      for (const sheetName in workbook.Sheets) {
          let sheet = sheetName.trim().toLocaleLowerCase();
          this.state.sheetsName.push(sheet);
          if (Object.hasOwnProperty.call(workbook.Sheets, sheetName)) {
            const XL_row_object = XLS.utils.sheet_to_row_object_array(
                workbook.Sheets[sheetName]
            );

            let csvData = [];
            const self = this;
            XL_row_object.forEach(function (row) {
              csvData.push(self.convertKeysToLowerCaseInExcelFile(row));
            });
            this.state.seedingDetails[sheet] = csvData;
          }
          this.state.csvDataResponse.push(XLS.utils.sheet_to_csv(workbook.Sheets[sheetName]));
      }
      this.importCatalogSeedingData();
    };
    reader.onerror = function (ex) {
      NotificationsUtilities.showToastMessageNotification(
        STATUS_MESSAGES.STATUS_ERROR_UPPERCASE,
        ex.message,
        STATUS_MESSAGES.STATUS_ERROR_LOWERCASE
      );
    };
    reader.readAsBinaryString(file);
  }

  downloadExcel(csvString) {

    // Create a new workbook
    const wb = XLS.utils.book_new();

    // Iterate over each CSV string and corresponding sheet name
    csvString.forEach((csv, index) => {
      // Parse CSV string into an array of arrays
      const rows = this.convertWithinQuotesValueAsSingle(csv);

      // Add the worksheet
      const ws = XLS.utils.aoa_to_sheet(rows);

      // Add the worksheet to the workbook with the corresponding sheet name
      XLS.utils.book_append_sheet(wb, ws, this.state.sheetsName[index]);
    });

    // Save the workbook as an Excel file
    XLS.writeFile(
      wb,
      this.state.selectedFiles[0].name.slice(0, -5) + " - Error.xlsx"
    );
  }

  convertWithinQuotesValueAsSingle(csv) {
    const rows = [];
    let currentRow = [];
    let withinQuotes = false;

    for (let i = 0; i < csv.length; i++) {
        if (csv[i] === ',' && !withinQuotes) {
        currentRow.push('');
        } else if (csv[i] === '"' && (i === 0 || csv[i - 1] !== '\\')) {
        withinQuotes = !withinQuotes;
        } else if (csv[i] === '\n' && !withinQuotes) {
        rows.push(currentRow);
        currentRow = [];
        } else {
        if (currentRow.length === 0) {
            currentRow.push(csv[i]);
        } else {
            currentRow[currentRow.length - 1] += csv[i];
        }
        }
    }

    if (currentRow.length > 0) {
        rows.push(currentRow);
    }
    return rows;
  }

  convertKeysToLowerCaseInExcelFile(jsonObj) {
    let newObject = {};
    for (let key in jsonObj) {
      if (Object.hasOwnProperty.call(jsonObj, key)) {
        const newKey = key.toLowerCase().replace(/\s+/g, '_').replace(/\?$/, '');
        newObject[newKey] = jsonObj[key];
      }
    }
    return newObject;
  }

  async importCatalogSeedingData() {
    this.state.isLoading = true;
    try {
      const results = await initiateSeedingProcess(
        JSON.stringify(this.state.seedingDetails),
        this.state.csvDataResponse,
      );
      if (results.errors) {
        if (Array.isArray(results.errors.body) && results.errors.body.length > 0) {
          this.downloadExcel(results.errors.body);
        }
        NotificationsUtilities.showToastMessageNotification(
          STATUS_MESSAGES.STATUS_ERROR_UPPERCASE,
          results.errors.message,
          STATUS_MESSAGES.STATUS_ERROR_LOWERCASE,
        );
      } else {
        NotificationsUtilities.showToastMessageNotification(
          STATUS_MESSAGES.STATUS_SUCCESS_UPPERCASE,
          results.results.message,
          STATUS_MESSAGES.STATUS_SUCCESS_LOWERCASE,
        );
      }
    } catch (error) {
      NotificationsUtilities.showToastMessageNotification(
        STATUS_MESSAGES.STATUS_ERROR_UPPERCASE,
        error.message,
        STATUS_MESSAGES.STATUS_ERROR_LOWERCASE,
      );
    } finally {
      this.state.selectedFiles = [];
      this.state.selectedFileName = '';
      this.state.csvDataResponse = [];
      this.state.seedingDetails = {};
      this.state.isLoading = false;
    }
  }

  convertKeysToLowerCaseInExcelFile(jsonObj) {
    let newObject = {};
    for (let key in jsonObj) {
      if (Object.hasOwnProperty.call(jsonObj, key)) {
        const newKey = key.toLowerCase().replace(/\s+/g, '_').replace(/\?$/, '');
        newObject[newKey] = jsonObj[key];
      }
    }
    return newObject;
  }

}