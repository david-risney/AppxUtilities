using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO.Compression;
using System.IO;

namespace ExtractFromAppx
{
    class Program
    {
        const int requiredParameterCount = 2;
        const int packageFilePathParameterIndex = 0;
        const int innerFilePathParameterIndex = 1;

        static string outputFileInZip(string zipFilePath, string innerFilePath)
        {
            ZipArchive zip = ZipFile.OpenRead(zipFilePath);
            Stream innerFileStream = zip.Entries.Where(entry => entry.FullName == innerFilePath || entry.Name == innerFilePath).FirstOrDefault().Open();
            StreamReader streamReader = new StreamReader(innerFileStream);
            return streamReader.ReadToEnd();
        }

        static void Main(string[] args)
        {
            if (args.Length == requiredParameterCount)
            {
                string packageFilePath = args[packageFilePathParameterIndex];
                string innerFilePath = args[innerFilePathParameterIndex];
                Console.Out.Write(outputFileInZip(packageFilePath, innerFilePath));
            }
            else
            {
                Console.Out.WriteLine("Output the text of a file from within an appx package\n" +
                    "\tExtractFromAppx [path to appx package] [path of file in package]\n");
            }
        }
    }
}
