#include "services/FileBridge.h"
#include "services/TextDirectionBridge.h"

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
        qmlRegisterSingletonInstance(
            "LeoMoon.ParsiNegar.Test", 1, 0, "NativeTextDirectionBridge", &m_textDirectionBridge);
    }

private:
    FileBridge m_fileBridge;
    TextDirectionBridge m_textDirectionBridge;
};

QUICK_TEST_MAIN_WITH_SETUP(parsinegar_ui, ParsiNegarTestSetup)

#include "ui_test_main.moc"
