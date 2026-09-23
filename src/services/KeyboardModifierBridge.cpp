#include "KeyboardModifierBridge.h"

#include <QCoreApplication>
#include <QEvent>
#include <QGuiApplication>
#include <QKeyEvent>

KeyboardModifierBridge::KeyboardModifierBridge(QObject *parent)
    : QObject(parent)
{
    QCoreApplication::instance()->installEventFilter(this);
    m_shiftReleaseTimer.setInterval(30);
    connect(&m_shiftReleaseTimer, &QTimer::timeout, this, [this]() {
        setShiftPressed(QGuiApplication::queryKeyboardModifiers().testFlag(Qt::ShiftModifier));
    });
}

KeyboardModifierBridge::~KeyboardModifierBridge()
{
    QCoreApplication::instance()->removeEventFilter(this);
}

bool KeyboardModifierBridge::shiftPressed() const
{
    return m_shiftPressed;
}

bool KeyboardModifierBridge::eventFilter(QObject *watched, QEvent *event)
{
    if (event->type() == QEvent::KeyPress || event->type() == QEvent::KeyRelease) {
        const auto *keyEvent = static_cast<QKeyEvent *>(event);
        const bool pressed = keyEvent->key() == Qt::Key_Shift
            ? event->type() == QEvent::KeyPress
            : keyEvent->modifiers().testFlag(Qt::ShiftModifier);
        setShiftPressed(pressed);
    } else if (event->type() == QEvent::ApplicationDeactivate) {
        setShiftPressed(false);
    }

    return QObject::eventFilter(watched, event);
}

void KeyboardModifierBridge::setShiftPressed(bool pressed)
{
    if (m_shiftPressed == pressed)
        return;

    m_shiftPressed = pressed;
    if (pressed)
        m_shiftReleaseTimer.start();
    else
        m_shiftReleaseTimer.stop();
    emit shiftPressedChanged();
}
