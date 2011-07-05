//
// configdialog.h - Configuration dialog
//
// by James L. Hammons
// (C) 2010 Underground Software
//

#ifndef __CONFIGDIALOG_H__
#define __CONFIGDIALOG_H__

#include <QtGui>

class GeneralTab;
class ControllerTab;

class ConfigDialog: public QDialog
{
	Q_OBJECT

	public:
		ConfigDialog(QWidget * parent = 0);
		~ConfigDialog();
		void UpdateVJSettings(void);

	private:
		void LoadDialogFromSettings(void);

	private:
		QTabWidget * tabWidget;
		QDialogButtonBox * buttonBox;

	public:
		GeneralTab * generalTab;
		ControllerTab * controllerTab;
};

#endif	// __CONFIGDIALOG_H__
