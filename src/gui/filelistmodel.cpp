//
// filelistmodel.cpp - A ROM chooser
//
// by James L. Hammons
// (C) 2010 Underground Software
//
// JLH = James L. Hammons <jlhamm@acm.org>
//
// Who  When        What
// ---  ----------  -------------------------------------------------------------
// JLH  02/01/2010  Created this file
// JLH  07/05/2011  Fixed model to not reset itself with each new row insertion
//

// Note that we have to put in convenience functions to the model for adding data
// and calling reset() to tell the view(s) that the model has changed. So that much
// should be simple. According to the docs, we have to reimplement flags() in the
// QAbstractListModel subclass, but in the example given below they don't. Not sure
// if it's necessary or not.

#include "filelistmodel.h"


FileListModel::FileListModel(QObject * parent/*= 0*/): QAbstractListModel(parent)
{
}

int FileListModel::rowCount(const QModelIndex & parent/*= QModelIndex()*/) const
{
	return list.size();
}

QVariant FileListModel::data(const QModelIndex & index, int role) const
{
	if (role == FLM_LABEL)
		return list.at(index.row()).label;
	else if (role == FLM_INDEX)
		return (uint)list.at(index.row()).dbIndex;
	else if (role == FLM_FILENAME)
		return list.at(index.row()).filename;
	else if (role == FLM_FILESIZE)
		return (uint)list.at(index.row()).fileSize;
	else if (role == FLM_UNIVERSALHDR)
		return (uint)list.at(index.row()).hasUniversalHeader;
	else if (role == FLM_FILETYPE)
		return (uint)list.at(index.row()).fileType;
	else if (role == FLM_CRC)
		return (uint)list.at(index.row()).crc;

	return QVariant();
}

QVariant FileListModel::headerData(int/* section*/, Qt::Orientation/* orientation*/, int role/*= Qt::DisplayRole*/) const
{
	// This seems more like what we want...
	if (role == Qt::SizeHintRole)
		return QSize(1, 1);

	return QVariant();
}

void FileListModel::AddData(unsigned long index, QString str, QImage img, unsigned long size)
{
	// Assuming that both QString and QImage have copy constructors, this should work.
	FileListData data;

	data.dbIndex = index;
	data.fileSize = size;
	data.filename = str;
	data.label = img;

	// Let's try this:
	beginInsertRows(QModelIndex(), list.size(), list.size());
	list.push_back(data);
	endInsertRows();
}

void FileListModel::AddData(unsigned long index, QString str, QImage img, unsigned long size, bool univHdr, uint32_t type, uint32_t fileCrc)
{
	// Assuming that both QString and QImage have copy constructors, this should work.
	FileListData data;

	data.dbIndex = index;
	data.fileSize = size;
	data.filename = str;
	data.label = img;
	data.hasUniversalHeader = univHdr;
	data.fileType = type;
	data.crc = fileCrc;

	// Let's try this:
	beginInsertRows(QModelIndex(), list.size(), list.size());
	list.push_back(data);
	endInsertRows();
}

void FileListModel::ClearData(void)
{
	if (list.size() == 0)
		return;

	beginResetModel();
	list.clear();
	endResetModel();
}

//FileListData FileListModel::GetData(const QModelIndex & index) const
//{
//	return list.at(index.row());
//}
