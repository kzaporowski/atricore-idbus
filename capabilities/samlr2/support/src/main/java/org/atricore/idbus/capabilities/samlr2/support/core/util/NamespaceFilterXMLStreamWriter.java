/*
 * Atricore IDBus
 *
 * Copyright (c) 2009, Atricore Inc.
 *
 * This is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this software; if not, write to the Free
 * Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA, or see the FSF site: http://www.fsf.org.
 */

package org.atricore.idbus.capabilities.samlr2.support.core.util;

import javax.xml.namespace.NamespaceContext;
import javax.xml.stream.XMLOutputFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamWriter;
import java.io.Writer;

/**
 * Helper class to make JAXB play nice with XMLDSig by removing corresponding prefixes from outcome
 *
 * @author <a href="mailto:gbrigand@josso.org">Gianluca Brigandi</a>
 * @version $Id$
 */
public class NamespaceFilterXMLStreamWriter implements XMLStreamWriter {

    private XMLStreamWriter xmlWriter;

    private String currentNs;

    public NamespaceFilterXMLStreamWriter(Writer writer) throws XMLStreamException {
        xmlWriter = XMLOutputFactory.newInstance().createXMLStreamWriter(writer);
    }

    public void writeStartElement(String localName) throws XMLStreamException {
        xmlWriter.writeStartElement(localName);
    }

    public void writeStartElement(String namespaceURI, String localName) throws XMLStreamException {
        xmlWriter.writeStartElement(namespaceURI, localName);
    }

    public void writeStartElement(String prefix, String localName, String namespaceURI) throws XMLStreamException {
        if (localName.equals("Signature")) {
            xmlWriter.writeStartElement(namespaceURI, localName);
            writeDefaultNamespace("http://www.w3.org/2000/09/xmldsig#");
        } else if (namespaceURI.equals("http://www.w3.org/2000/09/xmldsig#")) {
            xmlWriter.writeStartElement(namespaceURI, localName);
        } else {
            xmlWriter.writeStartElement(prefix, localName, namespaceURI);
        }
    }

    public void writeEmptyElement(String s, String s1) throws XMLStreamException {
        xmlWriter.writeEmptyElement(s, s1);
    }

    public void writeEmptyElement(String s, String s1, String s2) throws XMLStreamException {
        xmlWriter.writeEmptyElement(s, s1, s2);
    }

    public void writeEmptyElement(String s) throws XMLStreamException {
        xmlWriter.writeEmptyElement(s);
    }

    public void writeEndElement() throws XMLStreamException {
        xmlWriter.writeEndElement();
    }

    public void writeEndDocument() throws XMLStreamException {
        xmlWriter.writeEndDocument();
    }

    public void close() throws XMLStreamException {
        xmlWriter.close();
    }

    public void flush() throws XMLStreamException {
        xmlWriter.flush();
    }

    public void writeAttribute(String s, String s1) throws XMLStreamException {
        xmlWriter.writeAttribute(s, s1);
    }

    public void writeAttribute(String s, String s1, String s2, String s3) throws XMLStreamException {
        xmlWriter.writeAttribute(s, s1, s2, s3);
    }

    public void writeAttribute(String s, String s1, String s2) throws XMLStreamException {
        xmlWriter.writeAttribute(s, s1, s2);
    }

    public void writeNamespace(String s, String s1) throws XMLStreamException {
        xmlWriter.writeNamespace(s, s1);
    }

    public void writeDefaultNamespace(String s) throws XMLStreamException {
        xmlWriter.writeDefaultNamespace(s);
    }

    public void writeComment(String s) throws XMLStreamException {
        xmlWriter.writeComment(s);
    }

    public void writeProcessingInstruction(String s) throws XMLStreamException {
        xmlWriter.writeProcessingInstruction(s);
    }

    public void writeProcessingInstruction(String s, String s1) throws XMLStreamException {
        xmlWriter.writeProcessingInstruction(s, s1);
    }

    public void writeCData(String s) throws XMLStreamException {
        xmlWriter.writeCData(s);
    }

    public void writeDTD(String s) throws XMLStreamException {
        xmlWriter.writeDTD(s);
    }

    public void writeEntityRef(String s) throws XMLStreamException {
        xmlWriter.writeEntityRef(s);
    }

    public void writeStartDocument() throws XMLStreamException {
        xmlWriter.writeStartDocument();
    }

    public void writeStartDocument(String s) throws XMLStreamException {
        xmlWriter.writeStartDocument(s);
    }

    public void writeStartDocument(String s, String s1) throws XMLStreamException {
        xmlWriter.writeStartDocument(s, s1);
    }

    public void writeCharacters(String s) throws XMLStreamException {
        xmlWriter.writeCharacters(s);
    }

    public void writeCharacters(char[] chars, int i, int i1) throws XMLStreamException {
        xmlWriter.writeCharacters(chars, i, i1);
    }

    public String getPrefix(String s) throws XMLStreamException {
        return xmlWriter.getPrefix(s);
    }

    public void setPrefix(String s, String s1) throws XMLStreamException {
        xmlWriter.setPrefix(s, s1);
    }

    public void setDefaultNamespace(String s) throws XMLStreamException {
        xmlWriter.setDefaultNamespace(s);
    }

    public void setNamespaceContext(NamespaceContext namespaceContext) throws XMLStreamException {
        xmlWriter.setNamespaceContext(namespaceContext);
    }

    public NamespaceContext getNamespaceContext() {
        return xmlWriter.getNamespaceContext();
    }

    public Object getProperty(String s) throws IllegalArgumentException {
        return xmlWriter.getProperty(s);
    }
}

