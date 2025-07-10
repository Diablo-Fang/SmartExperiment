/****************************************************************************
** Meta object code from reading C++ file 'waveformplotter.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.15.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <memory>
#include "../../waveformplotter.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'waveformplotter.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.15.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
struct qt_meta_stringdata_WaveformPlotter_t {
    QByteArrayData data[13];
    char stringdata0[209];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_WaveformPlotter_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_WaveformPlotter_t qt_meta_stringdata_WaveformPlotter = {
    {
QT_MOC_LITERAL(0, 0, 15), // "WaveformPlotter"
QT_MOC_LITERAL(1, 16, 19), // "plotImageUrlChanged"
QT_MOC_LITERAL(2, 36, 0), // ""
QT_MOC_LITERAL(3, 37, 22), // "imageFilePrefixChanged"
QT_MOC_LITERAL(4, 60, 14), // "accumulateData"
QT_MOC_LITERAL(5, 75, 9), // "dataChunk"
QT_MOC_LITERAL(6, 85, 17), // "accumulateDataCH1"
QT_MOC_LITERAL(7, 103, 17), // "accumulateDataCH2"
QT_MOC_LITERAL(8, 121, 16), // "finalizePlotting"
QT_MOC_LITERAL(9, 138, 27), // "finalizeDualChannelPlotting"
QT_MOC_LITERAL(10, 166, 13), // "clearPlotData"
QT_MOC_LITERAL(11, 180, 12), // "plotImageUrl"
QT_MOC_LITERAL(12, 193, 15) // "imageFilePrefix"

    },
    "WaveformPlotter\0plotImageUrlChanged\0"
    "\0imageFilePrefixChanged\0accumulateData\0"
    "dataChunk\0accumulateDataCH1\0"
    "accumulateDataCH2\0finalizePlotting\0"
    "finalizeDualChannelPlotting\0clearPlotData\0"
    "plotImageUrl\0imageFilePrefix"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_WaveformPlotter[] = {

 // content:
       8,       // revision
       0,       // classname
       0,    0, // classinfo
       8,   14, // methods
       2,   68, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       2,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    0,   54,    2, 0x06 /* Public */,
       3,    0,   55,    2, 0x06 /* Public */,

 // methods: name, argc, parameters, tag, flags
       4,    1,   56,    2, 0x02 /* Public */,
       6,    1,   59,    2, 0x02 /* Public */,
       7,    1,   62,    2, 0x02 /* Public */,
       8,    0,   65,    2, 0x02 /* Public */,
       9,    0,   66,    2, 0x02 /* Public */,
      10,    0,   67,    2, 0x02 /* Public */,

 // signals: parameters
    QMetaType::Void,
    QMetaType::Void,

 // methods: parameters
    QMetaType::Void, QMetaType::QString,    5,
    QMetaType::Void, QMetaType::QString,    5,
    QMetaType::Void, QMetaType::QString,    5,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,

 // properties: name, type, flags
      11, QMetaType::QUrl, 0x00495001,
      12, QMetaType::QString, 0x00495103,

 // properties: notify_signal_id
       0,
       1,

       0        // eod
};

void WaveformPlotter::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<WaveformPlotter *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->plotImageUrlChanged(); break;
        case 1: _t->imageFilePrefixChanged(); break;
        case 2: _t->accumulateData((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 3: _t->accumulateDataCH1((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 4: _t->accumulateDataCH2((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 5: _t->finalizePlotting(); break;
        case 6: _t->finalizeDualChannelPlotting(); break;
        case 7: _t->clearPlotData(); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _t = void (WaveformPlotter::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&WaveformPlotter::plotImageUrlChanged)) {
                *result = 0;
                return;
            }
        }
        {
            using _t = void (WaveformPlotter::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&WaveformPlotter::imageFilePrefixChanged)) {
                *result = 1;
                return;
            }
        }
    }
#ifndef QT_NO_PROPERTIES
    else if (_c == QMetaObject::ReadProperty) {
        auto *_t = static_cast<WaveformPlotter *>(_o);
        Q_UNUSED(_t)
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< QUrl*>(_v) = _t->plotImageUrl(); break;
        case 1: *reinterpret_cast< QString*>(_v) = _t->imageFilePrefix(); break;
        default: break;
        }
    } else if (_c == QMetaObject::WriteProperty) {
        auto *_t = static_cast<WaveformPlotter *>(_o);
        Q_UNUSED(_t)
        void *_v = _a[0];
        switch (_id) {
        case 1: _t->setImageFilePrefix(*reinterpret_cast< QString*>(_v)); break;
        default: break;
        }
    } else if (_c == QMetaObject::ResetProperty) {
    }
#endif // QT_NO_PROPERTIES
}

QT_INIT_METAOBJECT const QMetaObject WaveformPlotter::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_WaveformPlotter.data,
    qt_meta_data_WaveformPlotter,
    qt_static_metacall,
    nullptr,
    nullptr
} };


const QMetaObject *WaveformPlotter::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *WaveformPlotter::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_WaveformPlotter.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int WaveformPlotter::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 8)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 8;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 8)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 8;
    }
#ifndef QT_NO_PROPERTIES
    else if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 2;
    } else if (_c == QMetaObject::QueryPropertyDesignable) {
        _id -= 2;
    } else if (_c == QMetaObject::QueryPropertyScriptable) {
        _id -= 2;
    } else if (_c == QMetaObject::QueryPropertyStored) {
        _id -= 2;
    } else if (_c == QMetaObject::QueryPropertyEditable) {
        _id -= 2;
    } else if (_c == QMetaObject::QueryPropertyUser) {
        _id -= 2;
    }
#endif // QT_NO_PROPERTIES
    return _id;
}

// SIGNAL 0
void WaveformPlotter::plotImageUrlChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void WaveformPlotter::imageFilePrefixChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
