#include "services/FileBridge.h"

#include <QtQuickTest/quicktest.h>
#include <qqml.h>

class ParsiNegarTestSetup final : public QObject
{
    Q_OBJECT

public slots:
    void applicationAvailable()
    {
        qmlRegisterSingletonInstance(
            "LeoMoon.ParsiNegar.Test", 1, 0, "NativeFileBridge", &m_fileBridge);
    }

private:
    FileBridge m_fileBridge;
};

QUICK_TEST_MAIN_WITH_SETUP(parsinegar_ui, ParsiNegarTestSetup)

#include "ui_test_main.moc"
